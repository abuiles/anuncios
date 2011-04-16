module OptionsParser
  def option opt, &block
    @opts[opt] = block
  end

  def call_option text
    opts = text.split(" ")
    opt = opts[0]
    args = opts[1..-1]
    if @opts.has_key? opt
      @opts[opt].call(*args)
    else
      puts "#{opt} command not found."
    end
  end

  def print_options
    puts "******************"
    puts "available options"
    @opts.keys.sort.each do |opt|
      puts opt
    end
    puts "******************"
    puts "Select one:"
  end
end
