#!/usr/bin/env ruby
# encoding: utf-8

require './lib/options_parser.rb'
require "rubygems"
require 'bundler'
Bundler.require(:default)

EventMachine.run do
  AMQP.connect(:host => 'localhost') do |connection|
    puts "starting producer"

    channel  = AMQP::Channel.new(connection)

    # Exit function
    quit = Proc.new {
      connection.close do
        EM.stop
        puts "Bye"
        exit
      end
    }

    Signal.trap "INT", quit
    Signal.trap "TERM", quit

    # Client logic below

    include OptionsParser
    @opts = {} # Needed by the parser

    # Commands
    option "quit" do
      quit.call
    end

    option "create" do |fanout|
      if fanout.nil?
        puts "You have to enter the name of the exchange"
      else
        channel.fanout(fanout)
        puts "#{fanout} created"
      end
    end

    option "send" do |fanout, *args|
        channel.fanout(fanout).publish(*args.join(" "))
        puts "Message Sent"
    end
    
    # Main loop, run in defer mode to allow the blocking IO
    # to work in conjunction with event machine
    operation = Proc.new {
      while true
        command = gets
        unless command.length == 1
          command.slice!(-1)
          call_option command
        end
      end
    }
    EventMachine.defer(operation,nil)
  end
end
