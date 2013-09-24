class Banned < ActiveRecord::Base
  validates_uniqueness_of :ban_value, :scope => [:ban_type], :message => ts("^That tag already seems to be in this set.")


end