class Poem < ActiveRecord::Base
  belongs_to :poet
  delegates :first_name, :to => :poet
  # Add a plain delegation to a normal Ruby object -- used in reflection_test.rb 
  # to verify that Streamlined doesn't break on delegates that AREN'T active record 
  # associations or aggregations
  delegates :current_time, :to => Time, :method => :now
end
