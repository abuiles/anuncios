#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require 'bundler'
Bundler.require(:default)

EventMachine.run do
  AMQP.connect(:host => 'localhost') do |connection|
    puts "starting client"

    channel  = AMQP::Channel.new(connection)
    queue    = channel.queue("amqpgem.examples.hello_world")

    queue.subscribe do |payload|
      puts "Receive: #{payload}. "
    end
  end
end
