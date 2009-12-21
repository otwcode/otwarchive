# This is essentially a mirror of the taggings table as applied to works (right now)
# except with all works connected to canonical tags instead of their synonyms for
# browsing and filtering purposes. Filter = tag, filterable = thing that's been tagged.
class FilterTagging < ActiveRecord::Base
  belongs_to :filter, :class_name => 'Tag'
  belongs_to :filterable, :polymorphic => true
  
  validates_presence_of :filter, :filterable
  
  # Build all filter taggings from current taggings data
  def self.build_from_taggings
    Tagging.find(:all, :conditions => {:taggable_type => 'Work'}).each do |tagging|
      if tagging.tagger && tagging.taggable
        tag = tagging.tagger.canonical? ? tagging.tagger : tagging.tagger.merger
        unless tag.nil? 
          tag.filter_taggings.create!(:filterable => tagging.taggable)
        end
      end
    end 
  end
  
  def self.update_filter_counts_since(date)
    if date
      filters = FilterTagging.find(:all, :include => :filter, :conditions => ["created_at > ?", date]).collect(&:filter).compact.uniq
      count = filters.length
      filters.each_with_index do |filter, i| 
        filter.reset_filter_count
        puts "Updating filter #{i + 1} of #{count} - #{filter.name}"
      end
    else
      raise "date not set for filter count suspension! very bad!"
    end
  end  
end