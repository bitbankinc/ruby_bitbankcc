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

bbcc = Bitbankcc.new("YOUR API KEY", "YOUR SECRET KEY")
bbcc.read_transactions('btc_jpy')
bbcc.read_ticker('btc_jpy')
bbcc.read_order_books('btc_jpy')
bbcc.read_balance()
bbcc.read_active_orders('btc_jpy')
bbcc.create_order('btc_jpy', "0.001", 130000, 'buy', 'limit')
bbcc.cancel_order('btc_jpy', order_id)
JSON.parse(response.body)
```
