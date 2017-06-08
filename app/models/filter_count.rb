class FilterCount < ActiveRecord::Base
  belongs_to :filter, class_name: 'Tag' 
  validates_presence_of :filter_id
  validates_uniqueness_of :filter_id
  
  # Set accurate filter counts for all canonical tags
  def self.set_all
    Tag.canonical.by_name.find_each do |filter|
      begin
#        puts "Resetting #{filter.name}"
         print "."; STDOUT.flush
        filter.reset_filter_count
      rescue
        puts "Problem resetting #{filter.name}"
      end
    end 
  end
end
