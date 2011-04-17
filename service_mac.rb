require 'drb'

# The difference between this and the linux one is that the
# command in this one is caled without sudo

class Service

  def list_exchanges
    exchanges = `rabbitmqctl list_exchanges`
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
