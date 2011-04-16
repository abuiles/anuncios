#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require 'bundler'
Bundler.require(:default)

EventMachine.run do
  AMQP.connect(:host => 'localhost') do |connection|
    puts "Starting server"

    channel  = AMQP::Channel.new(connection)
    exchange = channel.fanout("example_fanout")

    exchange.publish "The magic number is #{rand(20)}!"
  end
end
