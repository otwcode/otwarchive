class FilterCount < ActiveRecord::Base
  belongs_to :filter, :class_name => 'Tag' 
  validates_presence_of :filter_id
  validates_uniqueness_of :filter_id
  
  # Set accurate filter counts for all canonical tags
  def self.set_all
    filters = Tag.canonical
    filters.each do |filter|
      attributes = {:public_works_count => filter.filtered_works.posted.unhidden.unrestricted.count, 
                    :unhidden_works_count => filter.filtered_works.posted.unhidden.count}
      if filter.filter_count
        filter.filter_count.update_attributes(attributes)        
      else
        filter.create_filter_count(attributes)
      end
    end 
  end
end