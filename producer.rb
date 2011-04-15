require './lib/options_parser.rb'

include OptionsParser

# Array with the options
@opts = {}

# Exit function
# Close the connection and other stuff
def quit
  puts "Bye =)"
  exit
end

# Options
option "help" do
  opts = <<-OPTS
list
send <topic> <message>
create <topic>
quit
OPTS
  puts opts
end

option "list" do
  puts "List all topics"
end

option "send" do |*args|
  topic = args[0]
  text = args[1..-1].join(" ")
  if(args.length < 2)
    puts "To few parameters for the send option"
  else
    puts "Sending #{text} to #{topic} topic"
  end
end

option "create" do |*args|
  if(args.length < 1)
    puts "To few parameters for the create option"
  else
    puts "Creating #{args[0]} topic"
  end
end

option "quit" do
  quit
end

# The exit interruption
trap :INT do
  quit
end


while true
  command = STDIN.gets
  unless command.length == 1
    command.slice!(-1)
    call_option command
  end
end
