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
end