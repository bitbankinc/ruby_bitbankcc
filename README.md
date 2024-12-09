# RubyBitbankcc

This is ruby client implementation for Bitbankcc API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_bitbankcc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_bitbankcc

## Usage

```ruby
#!/usr/bin/env ruby -Ilib
require 'ruby_bitbankcc'

# use request_time method
bbcc = Bitbankcc.new("YOUR API KEY", "YOUR SECRET KEY",params= {"auth_method"=> "request_time", "time_window"=> "5000"})
# use nonce method
bbcc = Bitbankcc.new("YOUR API KEY", "YOUR SECRET KEY",params= {"auth_method"=> "nonce"})

bbcc.read_transactions('btc_jpy')
bbcc.read_ticker('btc_jpy')
bbcc.read_order_books('btc_jpy')
bbcc.read_balance()
bbcc.read_circuit_break_info('btc_jpy')
bbcc.read_active_orders('btc_jpy')
# you can omit last post_only (omit means false)
bbcc.create_order('btc_jpy', "0.001", 130000, 'buy', 'limit', false)
# you can omit last trigger_price (omit means nil)
bbcc.create_order('btc_jpy', "0.001", 130000, 'buy', 'stop_limit', false, 140000)
bbcc.cancel_order('btc_jpy', order_id)
bbcc.read_trade_history('btc_jpy')
bbcc.read_deposit_history('btc')
bbcc.read_withdrawal_account('btc')
bbcc.request_withdrawal('btc', 'ACCOUNT UUID', '0.001', 'OTP TOKEN', 'SMS TOKEN')
bbcc.read_withdrawal_history('btc')
JSON.parse(response.body)
```
