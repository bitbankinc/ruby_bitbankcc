require 'spec_helper'

APIKEY = ''
SECRETKEY = ''

describe RubyBitbankcc do
  it 'has a version number' do
    expect(RubyBitbankcc::VERSION).not_to be nil
  end

  it 'read transactions' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_transactions('btc_jpy')
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    res = bbcc.read_transactions('btc_jpy', '20170215')
    puts res
    expect(JSON.parse(res)['success']).to eq 1
  end

  it 'read ticker' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_ticker('btc_jpy')
    puts res
    expect(JSON.parse(res)['success']).to eq 1
  end

  it 'read order books' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_order_books('btc_jpy')
    puts res
    expect(JSON.parse(res)['success']).to eq 1
  end

  it 'generate signature' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    signature = bbcc.send(:get_signature, 'hogeho', '1492954196103/v1/user/assets')
    expect(signature).to eq 'e6230395d58ecae37ca0aad261ed278b38dd5751e24b101ef8a843de552674bf'
  end

  it 'read balance' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_balance()
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    sleep(1)
  end

  it 'read active orders' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_active_orders('btc_jpy')
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    sleep(1)
  end

  it 'read margin positions' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_margin_positions()
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    sleep(1)
  end

  it 'create order and cancel order' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.create_order('btc_jpy', "0.001", 130000, 'buy', 'limit')
    order_id = JSON.parse(res)['data']['order_id']
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    sleep(1)
    res = bbcc.cancel_order('btc_jpy', order_id)
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    sleep(1)
  end

  it 'create order with post_only and cancel order' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.create_order('btc_jpy', "0.001", 130000, 'buy', 'limit', true)
    order_id = JSON.parse(res)['data']['order_id']
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    sleep(1)
    res = bbcc.cancel_order('btc_jpy', order_id)
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    sleep(1)
  end

  it 'create order with trigger_price and cancel order' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.create_order('btc_jpy', "0.001", 130000, 'buy', 'stop_limit', false, 140000)
    order_id = JSON.parse(res)['data']['order_id']
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    sleep(1)
    res = bbcc.cancel_order('btc_jpy', order_id)
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    sleep(1)
  end

  it 'reads deposit history' do
    # before testing, we need some deposit history to test...
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_deposit_history('btc')
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    expect(JSON.parse(res)['data']['deposits'][0]['asset']).to eq 'btc'
    sleep(1)
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_deposit_history('jpy')
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    expect(JSON.parse(res)['data']['deposits'][0]['asset']).to eq 'jpy'
    sleep(1)
  end

  it 'reads withdrawal history' do
    # before testing, we need some withdrawal history to test...
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_withdrawal_history('btc')
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    expect(JSON.parse(res)['data']['withdrawals'][0]['asset']).to eq 'btc'
    expect(JSON.parse(res)['data']['withdrawals'][0]['address']).not_to be nil
    sleep(1)
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_withdrawal_history('jpy')
    puts res
    expect(JSON.parse(res)['success']).to eq 1
    expect(JSON.parse(res)['data']['withdrawals'][0]['asset']).to eq 'jpy'
    expect(JSON.parse(res)['data']['withdrawals'][0]['account_number']).not_to be nil
    sleep(1)
  end

  it 'read circuit_break_info' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_circuit_break_info('btc_jpy')
    puts res
    expect(JSON.parse(res)['success']).to eq 1
  end

  it 'read user subscribe' do
    bbcc = Bitbankcc.new(APIKEY, SECRETKEY)
    res = bbcc.read_user_subscribe()
    puts res
    expect(JSON.parse(res)['success']).to eq 1
  end
end
