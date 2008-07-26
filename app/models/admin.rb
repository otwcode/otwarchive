class Admin < ActiveRecord::Base
  acts_as_authentable(false)
end
