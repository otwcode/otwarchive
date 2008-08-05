require File.join(File.dirname(__FILE__), 'person') 

module PersonAdditions
  def full_name
    "#{first_name} #{last_name}"
  end
end

Person.class_eval { include PersonAdditions }