require 'test/unit'
#require 'test/unit/ui/console/testrunner'
require './polynomial'
 
class PolynomialTest < Test::Unit::TestCase
  def setup
    @p1 = Polynomial.new([-5,-2,1,0,8])
    @p2 = Polynomial.new([1,0,7])
    @p3 = Polynomial.new([-1,-2,3,0])
    @p4 = Polynomial.new([0,0,0])
    @p5 = Polynomial.new([0,-1,-2,0,0,7,0,-1,0,0])
  end
 
  def test_first_negative
    assert_equal("-5x^4-2x^3+x^2+8", @p1.to_s)
  end
 
  def test_simple
    assert_equal("x^2+7", @p2.to_s)
  end
 
  def test_first_minus_one
    assert_equal("-x^3-2x^2+3x", @p3.to_s)
  end
 
  def test_all_zero
    assert_equal("0", @p4.to_s)
  end
 
  def test_first_and_last_zero
    assert_equal("-x^8-2x^7+7x^4-x^2", @p5.to_s)
  end
 
  def test_error
    e = assert_raise(ArgumentError) { Polynomial.new([1]) }
    assert_match(/Two or more coefficients are required/, e.message)
  end
end
 
#Test::Unit::UI::Console::TestRunner.run(PolynomialTest)
