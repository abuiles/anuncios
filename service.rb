require 'drb'

class Service

  def list_exchanges
    exchanges = `sudo rabbitmqctl list_exchanges`
    puts exchanges
    topics = exchanges.lines.map{ |line| line[/(.*)\tfanout/, 1] }
    topics.compact!
    topics.delete_if{|topic| topic == 'amq.fanout'}
    topics
  end
end

service = Service.new
exchanges = service.list_exchanges
puts "The fanout exchanges are:"
puts exchanges

DRb.start_service "druby://localhost:9000", service

DRb.thread.join
