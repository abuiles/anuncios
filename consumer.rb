#!/usr/bin/env ruby
# encoding: utf-8

require './lib/options_parser.rb'
require "rubygems"
require 'bundler'
Bundler.require(:default)

EventMachine.run do
  AMQP.connect(:host => 'localhost') do |connection|
    puts "starting consumer"

    channel  = AMQP::Channel.new(connection)
    # Passing "" will make the server generate our own queue so we can listen to everything
    # We have to set nowait to false because we need the response from the server so we
    # know the queue name
    queue    = channel.queue("",:nowait => false)

    # Exit function, close the connection and stops the event machine
    quit = Proc.new {
      connection.close do
        EM.stop
        puts "Bye"
        exit
      end
    }

    # Trap the terminate signals
    Signal.trap "INT", quit
    Signal.trap "TERM", quit

    # Client logic below

    include OptionsParser
    @opts = {} # Needed by the parser

    # Commands
    option "quit" do
      quit.call
    end

    option "subscribe" do |fanout|
      # For now the fanout is irrelevant, it always subscribe to the same
      exchange = channel.fanout("example_fanout")

      queue.bind(exchange).subscribe do |payload|
        puts "Receive: #{payload}. "
      end
    end

    # Main loop, run in defer mode to allow the blocking IO
    # to work in conjunction with event machine
    operation = Proc.new {
      while true
        print_options
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

