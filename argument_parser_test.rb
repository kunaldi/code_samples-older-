require 'test/unit'
#require 'test/unit/ui/console/testrunner'
require './argument_parser'
 
class ArgumentParserTest < Test::Unit::TestCase
  def setup
    @ap = ArgumentParser.new
  end
 
  def test_simple
    assert_equal(["a", "b", "c"], @ap.parse("{a, b, c}"))
  end
  
  def test_escaped_1
    assert_equal(["a,b", "c"], @ap.parse("{a|,b, c}"))
  end
  
  def test_escaped_2
    assert_equal(["|, ,, "], @ap.parse("{||, |,|, }"))
  end

  def test_empty_args_1
    assert_equal(["", "", "a", ""], @ap.parse("{, , a, }"))
  end
  
  def test_escape_and_empty_1
    assert_equal(["| ", ",", ""], @ap.parse("{| , |,, }"))
  end
  
  def test_no_args
    assert_equal([""], @ap.parse("{}"))
  end
 
  def test_error_invalid_arg
    e = assert_raise(ArgumentError) { @ap.parse(1) }
    assert_match(/Args list is invalid/, e.message)    
    
    e = assert_raise(ArgumentError) { @ap.parse("}") }
    assert_match(/Args list is invalid/, e.message)
    
    e = assert_raise(ArgumentError) { @ap.parse("{") }
    assert_match(/Args list is invalid/, e.message)
        
    e = assert_raise(ArgumentError) { @ap.parse("{{}") }
    assert_match(/Args list is invalid/, e.message)
    
    e = assert_raise(ArgumentError) { @ap.parse("{}}") }
    assert_match(/Args list is invalid/, e.message)    
    
    e = assert_raise(ArgumentError) { @ap.parse("{a,b}") }
    assert_match(/Args list is invalid/, e.message)
  end
end
 
#Test::Unit::UI::Console::TestRunner.run(ArgumentParserTest)
