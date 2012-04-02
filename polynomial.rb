class Polynomial
  
  def initialize(elements=[])
    raise ArgumentError.new("Two or more coefficients are required") if elements.length < 2
    
    @values = elements
    @result = build_polynomial
  end

  def to_s
    @result
  end
  
  private
  
  def build_polynomial
    result = ''
    until @values.empty?
      coeff = @values.shift
      # if a coefficient is 0, nothing gets added to the output
      next if coeff == 0
      #if a coefficient is negative, you have to display something like "-5x^2", not "+-5x^2"
      sign = (coeff.is_a?(Numeric) && coeff < 0) ? '' : '+'
      # do not prepend + unless it is negative
      sign = '' if result.empty? && sign == '+'
      
      #if a coefficient is 1, it doesn't get printed
      coeff = case coeff
        when 1; ''
        when -1; '-'
        else; coeff
      end
      
      exp = @values.length
      # for x^1 the ^1 part gets omitted
      # x^0 == 1, so omit it otherwise build
      exp = if exp == 1 then 'x' else (exp == 0) ? '' : "x^#{exp}" end
      
      result << "#{sign}#{coeff}#{exp}" 
    end
    
    result = '0' if result.empty?
    result
  end

end
