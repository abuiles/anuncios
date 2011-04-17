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
    option "quit", "quit" do
      quit.call
    end

    option "help", "help" do
      print_options
    end

    option "create", "create soccer" do |fanout|
      if fanout.nil?
        puts "You have to enter the name of the exchange"
      else
        channel.fanout(fanout)
        puts "#{fanout} created"
      end
    end

    option "delete", "delete soccer" do |fanout|
      service = DRbObject.new nil, 'druby://'+ service_url
      exchanges = service.list_exchanges
      if(exchanges.include? fanout)
        begin
          puts "Notification sent, deleting.."
          channel.fanout(fanout).delete
        rescue
        end
      else
        puts "The exchange #{fanout} doesn't exists"
      end
    end

    option "list", "list" do
      service = (DRbObject.new nil, 'druby://'+ service_url)
      topics = service.list_exchanges
      puts "\n**********************************************"
      puts "The following topics are available:"
      puts topics
      puts "\n**********************************************"
    end

    option "send", "send soccer real madrid sucks" do |fanout, *args|
      service = DRbObject.new nil, 'druby://'+ service_url
      exchanges = service.list_exchanges
      if(exchanges.include? fanout)
        channel.fanout(fanout).publish("#{fanout}: #{args.join(" ")}")
        puts "Message Sent"
      else
        puts "The exchange #{fanout} does't exist"
      end
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
