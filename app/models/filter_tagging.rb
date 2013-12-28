# This is essentially a mirror of the taggings table as applied to works (right now)
# except with all works connected to canonical tags instead of their synonyms for
# browsing and filtering purposes. Filter = tag, filterable = thing that's been tagged.
class FilterTagging < ActiveRecord::Base
  self.primary_key = 'id'
  
  belongs_to :filter, :class_name => 'Tag'
  belongs_to :filterable, :polymorphic => true

  validates_presence_of :filter, :filterable

  def self.find(*args)
    raise "id is not guaranteed to be unique. please install composite_primary_keys gem and set the primary key to id,filter_id"
  end
  def self.find_by_id(id)
    raise "id is not guaranteed to be unique. please install composite_primary_keys gem and set the primary key to id,filter_id"
  end

  # Is this a valid filter tagging that should actually exist?
  def should_exist?
    return false unless self.filter && self.filter.canonical?
    tags = [self.filter] + self.filter.mergers + self.filter.meta_tags
    !(self.filterable.tags & tags).empty?
  end

  # Remove all invalid filter taggings
  def self.remove_invalid
    i = self.count
    self.find_each do |filter_tagging|
      begin
        puts "Checking #{i}"
        unless filter_tagging.should_exist?
          filter_tagging.destroy
        end
        i = i - 1
      rescue
        "Problem with filter tagging id:#{filter_tagging.id} filter_id:#{filter_tagging.filter_id}"
      end
    end
  end

  # Build all filter taggings from current taggings data
  def self.build_from_taggings
    Tagging.find(:all, :conditions => {:taggable_type => 'Work'}).each do |tagging|
      print "." if tagging.id.modulo(10) == 0; STDOUT.flush
      if tagging.tagger && tagging.taggable
        tag = tagging.tagger.canonical? ? tagging.tagger : tagging.tagger.merger
        if tag && tag.canonical?
          tag.filter_taggings.create!(:filterable => tagging.taggable)
        end
      end
    end
  end

  def self.update_filter_counts_since(date)
    if date
      filters = FilterTagging.includes(:filter).where("created_at > ?", date).collect(&:filter).compact.uniq
      count = filters.length
      filters.each_with_index do |filter, i|
        begin
          filter.reset_filter_count
          puts "Updating filter #{i + 1} of #{count} - #{filter.name}"
        rescue
          puts "Did not update filter #{i + 1} of #{count} - #{filter.name}"
        end
      end
    else
      raise "date not set for filter count suspension! very bad!"
    end
  end
end
