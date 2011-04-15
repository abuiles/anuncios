#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require 'bundler'
Bundler.require(:default)

EventMachine.run do
  AMQP.connect(:host => 'localhost') do |connection|
    puts "Starting server"

    channel  = AMQP::Channel.new(connection)
    queue    = channel.queue("amqpgem.examples.hello_world")
    exchange = channel.default_exchange

    exchange.publish "The magic number is #{rand(20)}!", :routing_key => queue.name
  end
end
