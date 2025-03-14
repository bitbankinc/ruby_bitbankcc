require 'net/http'
require 'uri'
require 'openssl'
require 'json'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'rest_client'

class Bitbankcc
  @@base_url = "https://api.bitbank.cc"
  @@base_public_url = "https://public.bitbank.cc"
  @@auth_method = "request_time"
  @@time_window = 5000
  @@ssl = true

  def initialize(key = nil, secret = nil, params = {})
    @key = key
    @secret = secret
    if !params[:base_url].nil?
      @@base_url = params[:base_url]
    end
    if !params[:auth_method].nil?
      @@auth_method = params[:auth_method]
    end
    if !params[:time_window].nil?
      @@time_window = params[:time_window]
    end
    if !params[:ssl].nil?
      @@ssl = params[:ssl]
    end
  end

  def read_balance
    path = "/v1/user/assets"
    nonce = get_current_milisec
    request_for_get(path, nonce)
  end

  def read_active_orders(pair, count = nil, from_id = nil, end_id = nil, since = nil, _end = nil)
    path = "/v1/user/spot/active_orders"
    nonce = get_current_milisec
    params = {
      pair: pair,
      count: count,
      from_id: from_id,
      end_id: end_id,
      since: since,
      end: _end
    }.compact
    request_for_get(path, nonce, params)
  end

  def read_margin_positions()
    path = "/v1/user/margin/positions"
    nonce = get_current_milisec
    request_for_get(path, nonce)
  end

  def create_order(pair, amount, price, side, type, post_only = false, trigger_price = nil, position_side = nil)
    path = "/v1/user/spot/order"
    nonce = get_current_milisec
    body = {
      pair: pair,
      amount: amount,
      price: price,
      side: side,
      type: type,
      post_only: post_only,
      trigger_price: trigger_price,
      position_side: position_side
    }.to_json
    request_for_post(path, nonce, body)
  end

  def cancel_order(pair, order_id)
    path = "/v1/user/spot/cancel_order"
    nonce = get_current_milisec
    body = {
      pair: pair,
      order_id: order_id
    }.to_json
    request_for_post(path, nonce, body)
  end

  def read_trade_history(pair, count = nil, order_id = nil, since = nil, _end = nil, order = nil)
    path = "/v1/user/spot/trade_history"
    nonce = get_current_milisec
    params = {
      pair: pair,
      count: count,
      order_id: order_id,
      since: since,
      end: _end,
      order: order
    }.compact

    request_for_get(path, nonce, params)
  end

  def read_deposit_history(asset, count = nil, since = nil, _end = nil, order = nil)
    path = "/v1/user/deposit_history"
    nonce = get_current_milisec
    params = {
      asset: asset,
      count: count,
      since: since,
      end: _end,
      order: order
    }.compact

    request_for_get(path, nonce, params)
  end

  def read_withdrawal_account(asset)
    path = "/v1/user/withdrawal_account"
    nonce = get_current_milisec
    params = {
      asset: asset
    }.compact

    request_for_get(path, nonce, params)
  end

  def request_withdrawal(asset, uuid, amount, otp_token = nil, sms_token = nil)
    path = "/v1/user/request_withdrawal"
    nonce = get_current_milisec
    body = {
      asset: asset,
      uuid: uuid,
      amount: amount,
      otp_token: otp_token,
      sms_token: sms_token
    }.compact.to_json
    request_for_post(path, nonce, body)
  end

  def read_withdrawal_history(asset, count = nil, since = nil, _end = nil, order = nil)
    path = "/v1/user/withdrawal_history"
    nonce = get_current_milisec
    params = {
      asset: asset,
      count: count,
      since: since,
      end: _end,
      order: order
    }.compact

    request_for_get(path, nonce, params)
  end

  def read_ticker(pair)
    RestClient.get @@base_public_url + "/#{pair}/ticker"
  end

  def read_order_books(pair)
    RestClient.get @@base_public_url + "/#{pair}/depth"
  end

  def read_transactions(pair, date = '')
    RestClient.get @@base_public_url + "/#{pair}/transactions" + (date.empty? ? '' : '/' + date)
  end

  def read_circuit_break_info(pair)
    RestClient.get @@base_public_url + "/#{pair}/circuit_break_info"
  end

  private
    def http_request(uri, request)
      https = Net::HTTP.new(uri.host, uri.port)

      if @@ssl
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = https.start do |h|
        h.request(request)
      end
      # XXX: I think we should JSON.parse it, but it makes backward incompatibility. What do you think, code wanderers?
      response.body
    end


    def make_nonce_header(message, api_key, secret_key, nonce)
      signature = get_signature(secret_key, message)
      headers = {
        "Content-Type" => "application/json",
        "ACCESS-KEY" => api_key,
        "ACCESS-NONCE" => nonce,
        "ACCESS-SIGNATURE" => signature
      }
    end

    def make_request_time_header(message, api_key, secret_key, request_time, time_window)
      signature = get_signature(secret_key, message)
      headers = {
        "Content-Type" => "application/json",
        "ACCESS-KEY" => api_key,
        "ACCESS-REQUEST-TIME" => request_time,
        "ACCESS-TIME-WINDOW" => time_window.to_s,
        "ACCESS-SIGNATURE" => signature
      }
    end

    def request_for_get(path, nonce, query = {})
      uri = URI.parse @@base_url + path
      query_string = query.present? ? '?' + query.to_query : ''
      if @@auth_method == "request_time"
        request_time = get_current_milisec
        message = request_time + @@time_window.to_s + path + query_string
        headers = make_request_time_header(message, @key, @secret, request_time, @@time_window)
      else
        nonce = get_current_milisec
        headers = make_nonce_header(path,nonce)
        message = nonce + path + query_string
        headers = make_nonce_header(message, @key, @secret, nonce)
      end
      uri.query = query.to_query
      request = Net::HTTP::Get.new(uri.request_uri, initheader = headers)
      http_request(uri, request)
    end

    def request_for_post(path, nonce, body)
      uri = URI.parse @@base_url + path
      if @@auth_method == "request_time"
        request_time = get_current_milisec
        message = request_time + @@time_window.to_s + body
        headers = make_request_time_header(message, @key, @secret, request_time, @@time_window)
      else
        nonce = get_current_milisec
        headers = make_nonce_header(path,nonce)
        message = nonce + body
        headers = make_nonce_header(message, @key, @secret, nonce)
      end

      request = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
      request.body = body

      http_request(uri, request)
    end

    def get_current_milisec
      (Time.now.to_f * 1000.0).to_i.to_s
    end

    def get_signature(secret_key, message)
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret_key, message)
    end
end
