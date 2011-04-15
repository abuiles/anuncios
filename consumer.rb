require './lib/options_parser.rb'

include OptionsParser

# Array with the options (Required by the parser)
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
subscribe <topic>
quit
OPTS
  puts opts
end

option "list" do
  puts "List all topics"
end

option "subscribe" do |*args|
  if(args.length < 1)
    puts "To few parameters for the create option"
  else
    topic = args[0]
    puts "Subscribing to #{topic}"
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
