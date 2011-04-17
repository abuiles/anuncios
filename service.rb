require 'drb'

class Service
  def initialize pass
    @pass = pass
  end

  def list_exchanges
    exchanges = `sudo -p #{@pass} rabbitmqctl list_exchanges`
    topics = exchanges.lines.map{ |line| line[/(.*)\tfanout/, 1] }
    topics.compact!
    topics.delete_if{|topic| topic == 'amq.fanout'}
    topics
  end
end

service = Service.new(ARGV[0] || "")
puts service.list_exchanges

DRb.start_service "druby://localhost:9000", service

DRb.thread.join
