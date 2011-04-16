#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require 'bundler'
Bundler.require(:default)

EventMachine.run do
  AMQP.connect(:host => 'localhost') do |connection|
    puts "starting client"

    channel  = AMQP::Channel.new(connection)
    # Passing "" will make the server generate our own queue so we can listen to everything
    # We have to set nowait to false because we need the response from the server so we
    # know the queue name
    queue    = channel.queue("",:nowait => false)
    exchange = channel.fanout("example_fanout")

    # We set the queue listen to the example exchange
    queue.bind(exchange).subscribe do |payload|
      puts "Receive: #{payload}. "
    end
  end
end
