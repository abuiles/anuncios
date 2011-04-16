module OptionsParser
  def option (opt, use, &block)
    @opts[opt] = {}
    @opts[opt][:block] = block
    @opts[opt][:use] = use
  end

  def call_option text
    opts = text.split(" ")
    opt = opts[0]
    args = opts[1..-1]
    if @opts.has_key? opt
      @opts[opt][:block].call(*args)
    else
      puts "#{opt} command not found."
    end
  end

  def print_options
    puts "******************"
    puts "Available options"
    @opts.keys.sort.each do |opt|
      puts "#{opt} -- Usage: #{@opts[opt][:use]}"
    end
    puts "******************"
    puts "Select one:"
  end
end
