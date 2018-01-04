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
  @@ssl = true

  def initialize(key = nil, secret = nil, params = {})
    @key = key
    @secret = secret
    if params[:base_url]
      @@base_url = params[:base_url]
    end
    if params[:ssl]
      @@ssl = params[:ssl]
    end
  end

  def read_balance
    path = "/v1/user/assets"
    nonce = Time.now.to_i.to_s
    request_for_get(path, nonce)
  end

  def read_active_orders(pair, count = nil, from_id = nil, end_id = nil, since = nil, _end = nil)
    path = "/v1/user/spot/active_orders"
    nonce = Time.now.to_i.to_s
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

  def create_order(pair, amount, price, side, type)
    path = "/v1/user/spot/order"
    nonce = Time.now.to_i.to_s
    body = {
      pair: pair,
      amount: amount,
      price: price,
      side: side,
      type: type
    }.to_json
    request_for_post(path, nonce, body)
  end

  def cancel_order(pair, order_id)
    path = "/v1/user/spot/cancel_order"
    nonce = Time.now.to_i.to_s
    body = {
      pair: pair,
      order_id: order_id
    }.to_json
    request_for_post(path, nonce, body)
  end

  def read_trade_history(pair, count = nil, order_id = nil, since = nil, _end = nil, order = nil)
    path = "/v1/user/spot/trade_history"
    nonce = Time.now.to_i.to_s
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

  def read_withdrawal_account(asset)
    path = "/v1/user/withdrawal_account"
    nonce = Time.now.to_i.to_s
    params = {
      asset: asset
    }.compact

    request_for_get(path, nonce, params)
  end

  def request_withdrawal(asset, uuid, amount, otp_token = nil, sms_token = nil)
    path = "/v1/user/request_withdrawal"
    nonce = Time.now.to_i.to_s
    body = {
      asset: asset,
      uuid: uuid,
      amount: amount,
      otp_token: otp_token,
      sms_token: sms_token
    }.compact.to_json
    request_for_post(path, nonce, body)
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
      response.body
    end

    def request_for_get(path, nonce, query = {})
      uri = URI.parse @@base_url + path
      signature = get_get_signature(path, @secret, nonce, query)

      headers = {
        "Content-Type" => "application/json",
        "ACCESS-KEY" => @key,
        "ACCESS-NONCE" => nonce,
        "ACCESS-SIGNATURE" => signature
      }

      uri.query = query.to_query
      request = Net::HTTP::Get.new(uri.request_uri, initheader = headers)
      http_request(uri, request)
    end

    def request_for_post(path, nonce, body)
      uri = URI.parse @@base_url + path
      signature = get_post_signature(@secret, nonce, body)

      headers = {
        "Content-Type" => "application/json",
        "ACCESS-KEY" => @key,
        "ACCESS-NONCE" => nonce,
        "ACCESS-SIGNATURE" => signature,
        "ACCEPT" => "application/json"
      }

      request = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
      request.body = body

      http_request(uri, request)
    end

    def get_get_signature(path, secret_key, nonce, query = {})
      query_string = query.present? ? '?' + query.to_query : ''
      message = nonce + path + query_string
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret_key, message)
    end

    def get_post_signature(secret_key, nonce, body = "")
      message = nonce + body
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret_key, message)
    end
end
