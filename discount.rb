require 'digest/md5'

class Discount < ActiveRecord::Base
  belongs_to :brand

  validates :start_date, :presence => {:message => "Please provide a start date for this discount."}
  validates :code, :presence => {:message => "Please provide a discount code."}
  validates :currency_cd, :presence => {:message => "Please select currency."}
  validates :brand_id, :presence => {:message => "Please select brand."}

  validates :code, :uniqueness => {:scope => :start_date, :message => "Discount already exists"}
  validates :code, :uniqueness => {:message => "Discount already exists"}

  validates_each :start_date, do |record, attr, value|
    record.errors.add attr, "Start date is in the past. It must be at the current date or the future" if record.new_record? && record.start_date && record.start_date < Date.today
  end

  validates_each :end_date do |record, attr, value|
    record.errors.add attr, "End date must be after start date" if record.end_date && record.start_date && record.start_date > record.end_date
    record.errors.add attr, "End date must set to tomorrow or a later date." if record.end_date && record.end_date < Date.today+1
  end

  validates_each :eligibility_hash do |record, attr|
    record.eligibility_hash.each{|k, v| record.errors.add "", "You must supply a value to '#{k}'" if v.blank?}
    if record.eligibility_hash.has_key?(:customer_created_before) and record.eligibility_hash[:customer_created_before].is_a?(String)
      begin
        record.eligibility_hash[:customer_created_before].to_date
      rescue ArgumentError => err
        record.errors.add "", "You have entered an invalid date for the customer created before check. Format should be d/m/Y."
      end
    end
  end

  validate :action_validate

  before_save {|record|
    if record.eligibility_hash.has_key?(:customer_created_before) and record.eligibility_hash[:customer_created_before].is_a?(String)
      record.eligibility_hash[:customer_created_before] = record.eligibility_hash[:customer_created_before].to_date
    end
    record.eligibility_hash = Marshal.dump(record.eligibility_hash)
  }

  scope :by_code, lambda {|code|
    where("upper(code) like ?", "%#{code.to_s.upcase}%").order("code ASC")
  }

  def eligibility_hash
    if self['eligibility_hash'] && self['eligibility_hash'].is_a?(String)
      self['eligibility_hash'] = Marshal.load(self['eligibility_hash'])
    end
    self['eligibility_hash'] || {}
  end

  def stackable?;  stackable_flg end

  def status
      return 'enabled' if active_flg && (!end_date or end_date && end_date>= Date.today)
      return 'expired'  if end_date && end_date < Date.today
      return 'disabled' unless active_flg
      "unknown"
  end

  def enabled?
    return status == 'enabled'
  end

  def action_validate
    errors.add "","Discount can't be updated since there are active instances of it." if !self.new_record? && count_active_instances>0
  end

  def count_active_instances
    self.class.count_by_sql([
      "SELECT
      COUNT(di.id)
    FROM discount_instances di
      INNER JOIN loans l on l.id = di.loan_id
      AND l.status_cd not in ('withdrawn', 'declined')
    WHERE
      di.discount_id = ?
      AND di.confirmed_on is NOT NULL
      AND expired_flg='f'", id])
  end

end
