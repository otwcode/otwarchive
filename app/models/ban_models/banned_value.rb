class BannedValue < ActiveRecord::Base
  validates_uniqueness_of :name, :scope => [:ban_type], :message => ts("^That tag already seems to be in this set.")

  def add_email(email)
    my_banned_value = BannedValue.new
    my_banned_value.name = email
    my_banned_value.ban_type = 1
    puts(my_banned_value.name)
    puts(my_banned_value.ban_type)
    my_banned_value.save
  end


end