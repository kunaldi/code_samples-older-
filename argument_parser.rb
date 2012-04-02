class ArgumentParser
  def parse(args)
    if args.is_a?(String) && args.size >= 2
      if '{}' == args.slice!(0) << args.slice!(-1)
        unless args =~ /[\{\}]/ || args =~ /[^\|],[^ ]/
          args = args.gsub(/\|,/, '$') || args
          return args.concat('@').split(', ').each {|a| a.gsub!(/\$/, ','); a.gsub!('@', '')}
        end
      end
    end
    
    raise ArgumentError.new("Args list is invalid") 
  end
end