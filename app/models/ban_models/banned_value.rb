class BannedValue < ActiveRecord::Base
  validates_uniqueness_of :name, :scope => [:type], :message => ts("^That tag already seems to be in this set.")

  attr_accessor(:name)
  attr_accessor(:type)

  def add_email(email)
    banned_value = BannedValue.new
    banned_value.name = email
    banned_value.type = 1
    banned_value.save
  end


end