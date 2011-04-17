require 'drb'

def list_exchanges
  return ["ejemplo1", "ejemplo"]
end

DRb.start_service "druby://localhost:9000", list_exchanges

DRb.thread.join
