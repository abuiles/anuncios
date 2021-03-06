#!/usr/bin/env ruby
# encoding: utf-8

require 'drb'
require './lib/options_parser.rb'
require "rubygems"
require 'bundler'
Bundler.require(:default)

# URL to the service that tells the list of queues
service_url = ARGV[1] || "localhost:9000"

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
    option "quit", "quit" do
      quit.call
    end

    option "help", "help" do
      print_options
    end

    option "subscribe", "subscribe soccer" do |fanout|
      service = (DRbObject.new nil, 'druby://'+ service_url)
      exchanges = service.list_exchanges
      if exchanges.include?(fanout)
        exchange = channel.fanout(fanout)

        begin
          queue.bind(exchange).subscribe do |payload|
            puts "#{payload}"
          end
        rescue
        end

        puts "Subscribed to #{fanout}"
      else
        puts "The exchange #{fanout} doesn't exists"
      end
    end

    option "list", "list" do
      service = (DRbObject.new nil, 'druby://'+ service_url)
      topics = service.list_exchanges
      puts "\n**********************************************"
      puts "You can subscribe to any of the following topics"
      puts topics
      puts "\nExample of subcription: subcribe #{topics[rand(topics.size)]}"
      puts "\n**********************************************"
    end

    # Main loop, run in defer mode to allow the blocking IO
    # to work in conjunction with event machine
    operation = Proc.new {
      print_options
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

