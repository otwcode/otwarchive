class Poet < ActiveRecord::Base
  has_many :poems
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  # used to test reflection protection for sort_models
  def dangerous!; end
    
end
