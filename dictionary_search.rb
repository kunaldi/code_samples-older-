class DictionarySearch
  def initialize(file_path)
    @words = []
    
    File.open(file_path, 'r').each_line do |w|
      @words << w.chomp if w.length > 4
    end
  end
  
  def word_pairs
    result = []
    @words.group_by {|v| v[0..-3]}.reject! {|k, v| v.count < 2}.each_value do |v|
      words = v.clone
      
      until words.empty?
        w1 = words.shift
        body = w1[0..-3]
        l1 = w1[-2..-2]
        l2 = w1[-1..-1]
        
        w2 = "#{body}#{l2}#{l1}"
        result << [w1, w2] if words.include?(w2)
      end
    end
    
    #puts result.inspect
    puts "Found #{result.size} matching pairs"
    result
  end
end