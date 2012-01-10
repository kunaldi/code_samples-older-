require 'variables/raw_variable'

class Variable < ActiveRecord::Base
  set_table_name 'mef.variables'
  set_sequence_name "mef.variables_id_seq" 
  include RawVariable
  belongs_to  :variable_type   
  belongs_to  :equation
  belongs_to  :direct_access_table_name
  
  validates :variable_name, :presence => true
  validates :variable_type_id, :presence => {:message => 'must be selected'}
  validates :variable_name, :uniqueness => {:scope => :equation_id}
  
  validate :action_validate
  
  scope :all_variables_ordered, order('variable_type_id, variable_name')
  #
  #scope :preferred_order, lambda {|name_cond|
  #  where("variable_name like ?", name_cond).
  #  order("variable_type_id, variable_name")
  #}
 
  ALLOWED_OPERATORS = { "bucket_raw" => ['le' , 'eq', 'ge', 'lt', 'gt', 'match', 'notmatch', 'istrue', 'isfalse', 'isnil', 'isnilorempty', 'include', 'startsWith' , 'strContain'],
                        "bucket_composite" => ['le' , 'eq', 'ge', 'lt', 'gt']}

  def editable?
    EquationVariable.find_by_variable_id(self.id).nil? &&
      EquationSampleVariable.find_by_variable_id(self.id).nil? &&
      SelectorRule.where("use_rule like ?", "%#{self.variable_name.to_s}%").size == 0 &&
      SelectorRule.find_by_variable_id(self.id).nil?
  end

  class << self
    def get_variable_list
      variables.collect{|v| [v.variable_name, v.id]}
    end
    
    def filter(q)
      res = all_variables_ordered
      res = res.where("variable_name LIKE ?", "%#{q}%") if q
      res
    end
  end
  
  def variable_type_name
    variable_type && variable_type.variable_type
  end
  
protected
  def isNumeric?(str)
    Float(str) != nil rescue false
  end
  
  def action_validate
    if(variable_type && ['composite', 'bucket_composite'].include?(variable_type.variable_type) && equation_id.nil? )
      errors.add("variable_type", "Variable Type cannot be 'composite' without an associated equation")
    end

    # We should allow -. as some of the strings in veda reports are "no-match" etc... - Jimish
    if(variable_name !~ /^[-a-zA-Z\d_\|]+$/)
      errors.add(:variable_name, "Variable Name needs to be alphanumeric")
    end

    if(equation_id && (!variable_type || !['composite', 'bucket_composite'].include?(variable_type.variable_type)))
      errors.add(:variable_type, "Variable Type must be composite if associated to an equation")
    end

    # person cannot create variable if it's not composite if it not in RawVariable.instance_methods
    if (variable_type ) && 
        (variable_type.variable_type == 'bucket_raw' ||
         variable_type.variable_type == 'raw' ||
         variable_type.variable_type == 'has_coefficient_overrides') &&
        !RawVariable.instance_methods.include?(variable_name.split('__')[0].sub('lookup_', '')) &&
        direct_access_table_name.nil?      
      errors.add(:variable_name, "Variable #{variable_name.split('__')[0].sub('lookup_', '')} is not implemented1")
    end

    # bucket composites must be named according to the associated equation
    if equation_id && variable_type && 
                      variable_type.variable_type == 'bucket_composite' &&
                    !(variable_name.split('__')[0] == Equation.find_by_id(equation_id).equation_name)
      errors.add(:variable_name, "Variable Name must include Equation Name for bucket_composite type")
    end

    if variable_type_name == 'direct_access' and !direct_access_table_name
        errors.add(:variable_name, "Direct Access Variable #{variable_name.split('__')[0].sub('lookup_', '')} does not have associated table")
    end
    

    if variable_type && (variable_type.variable_type == 'bucket_composite') && variable_name.split('__').size == 1
      errors.add(:variable_name, "Invalid name format for bucket_composite variable #{variable_name} ")
    end

    if variable_type && variable_type.variable_type == 'bucket_raw' && variable_name.split('__').size == 1
      errors.add(:variable_name, "Invalid name format for bucket_raw variable #{variable_name} ")
    end
  
    if variable_type && ['bucket_raw', 'bucket_composite'].include?(variable_type.variable_type)
      vars = variable_name.split('__')
      return if 1 == vars.size
      sp = vars[1].split(/_/)
      if(!ALLOWED_OPERATORS[variable_type.variable_type].include?(sp[0]))
        errors.add(:variable_name, "Invalid operator '#{sp[0]}' was used in bucket variable")
      elsif(['le' , 'eq', 'ge', 'lt', 'gt'].include?(sp[0]) && sp.size > 1)
        if !isNumeric?(sp[1].gsub('dot','.').gsub('minus','-'))
          errors.add(:variable_name, "Invalid comparison: #{sp[1]} is not a number")
        end
        #checked first parameter
        if sp.size > 2
          if(!['le' , 'eq', 'ge', 'lt', 'gt'].include?(sp[2]))
            errors.add(:variable_name, "Invalid operator '#{sp[2]}' was used in bucket variable")
          else
            if !isNumeric?(sp[3].gsub('dot','.').gsub('minus','-'))
              errors.add(:variable_name, "Invalid comparison: #{sp[3]} is not a number")
            end
          end
        end
      end
    end

    if variable_type && (variable_type.variable_type == 'raw' || variable_type.variable_type == 'composite') && variable_name.split('__').size == 2
      errors.add(:variable_name, "Invalid name format for the selected variable type")
    end
  
    if variable_type && (variable_type.variable_type == 'has_coefficient_overrides') && variable_name !~ /lookup_/
      errors.add(:variable_name, "Invalid name format for has_coefficient_overrides variable #{variable_name}. Must begin with lookup_")
    end
 
  end
  
end
