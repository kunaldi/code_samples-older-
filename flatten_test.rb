# A sample code of a plain Ruby substitution of
# enumerator Flatten method with multiple nested
# Hash + Array flattening for a given level

class MyTest
    def my_flatten(data, level)
        result = flatten(data,level)
        puts "#{result.inspect}"
    end
    
    private
    
    def flatten(data, level)
        data.inject([]) {|f, i|
            if level > 0
                if ["Array", "Hash"].include?(i.class.name)
                    i = flatten(i, level-1)
                    f.concat(i)
                    next f
                end
            elsif level == 0 and i.is_a? Array
                f.concat(i)
                next f
            end
            
            f.push(i)
            f
        }
    end
end


values = {   1 => "one (lv0)",
            "2" => [2, "two (lv1)"],
            3 => [3, "three (lv1)",
                    [99, 'abc (lv2)',
                        {:col1 => 'red (lv4)', 'col2' => :white,
                            8 => [:blue, "green (lv5)", 12] }]],
            :apple => { :level => 'lv2',
                        :ipod => true,
                        :imac => 2300,
                        :iweb => [1.9, 'online (lv3)'] }
        }
 
MyTest.new.my_flatten(values, ARGV[0].to_i)
