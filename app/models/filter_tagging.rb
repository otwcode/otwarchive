# This is essentially a mirror of the taggings table as applied to works (right now)
# except with all works connected to canonical tags instead of their synonyms for
# browsing and filtering purposes. Filter = tag, filterable = thing that's been tagged.
class FilterTagging < ActiveRecord::Base
  belongs_to :filter, :class_name => 'Tag'
  belongs_to :filterable, :polymorphic => true
  
  validates_presence_of :filter, :filterable
  
  after_create :increment_filter_count
  before_destroy :decrement_filter_count
  
  #TODO: reduce duplication
  def increment_filter_count
    if self.filterable.is_a?(Work) && self.filterable.posted? && !self.filterable.hidden_by_admin?
      filter_count = FilterCount.find_or_create_by_filter_id(self.filter_id)
      attributes = {:unhidden_works_count => filter_count.unhidden_works_count + 1}
      unless self.filterable.restricted?
        attributes[:public_works_count] = filter_count.public_works_count + 1
      end
      filter_count.update_attributes(attributes)
    end
  end
  
  def decrement_filter_count
    if self.filterable.is_a?(Work) && self.filterable.posted? && !self.filterable.hidden_by_admin?
      filter_count = self.filter.filter_count
      if filter_count
        attributes = {:unhidden_works_count => filter_count.unhidden_works_count - 1}
        unless self.filterable.restricted?
          attributes[:public_works_count] = filter_count.public_works_count - 1
        end
        filter_count.update_attributes(attributes)
      end
    end    
  end
  
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
end