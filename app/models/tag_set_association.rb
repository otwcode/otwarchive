class TagSetAssociation < ActiveRecord::Base
  belongs_to :owned_tag_set
  belongs_to :tag
  belongs_to :parent_tag, :class_name => "Tag"

  validates_uniqueness_of :tag_id, :scope => [:owned_tag_set_id, :parent_tag_id], :message => ts("^You have already associated those tags in your set.")
  validates_presence_of :tag_id, :parent_tag_id, :owned_tag_set_id

  validate :not_existing
  def not_existing
    # not already existing 
    if parent_tag && parent_tag.children.where(:id => tag.id).exists?
      errors.add(:base, "^The tags #{tag.name} and #{parent_tag.name} are already canonically associated.")
    end
  end
  
  attr_accessor :create_association
  
  def self.for_tag_set(tagset)
    where(:owned_tag_set_id => tagset.id)
  end

  def parent_tagname
    @parent_tagname || self.parent_tag.name
  end
  
  def parent_tagname=(parent_tagname)
    self.parent_tag = Tag.find_by_name(parent_tagname)
  end
  
  def make_official!
    tag.add_association(parent_tag)
    self.destroy
  end
  
  after_save :add_to_autocomplete
  before_destroy :remove_from_autocomplete
  
  ## AUTOCOMPLETE
  # set up autocomplete and override some methods
  include AutocompleteSource
  
  def autocomplete_prefixes
    prefixes = [ ]
    prefixes
  end
  
  # the value and score in autocomplete are the value/score of the child tag
  def autocomplete_value
    tag.autocomplete_value
  end

  def autocomplete_score
    tag.autocomplete_score
  end

  def self.parse_autocomplete_value(current_autocomplete_value)
    Tag.parse_autocomplete_value(current_autocomplete_value)
  end
      
  def add_to_autocomplete(score = nil)
    score ||= autocomplete_score
    $redis.zadd("autocomplete_association_#{tag.type.downcase}_#{owned_tag_set.id}_#{parent_tag.name.downcase}", score, autocomplete_value)
  end

  def remove_from_autocomplete
    $redis.zrem("autocomplete_association_#{tag.type.downcase}_#{owned_tag_set.id}_#{parent_tag.name.downcase}", autocomplete_value)
  end
    
  # returns tags that have been associated with a given fandom OR wrangled
  def self.autocomplete_lookup(options = {})
    options.reverse_merge!({:term => "", :tag_type => "character", :tag_set => "", :fandom => "", :include_wrangled => "true"})
    search_param = options[:term]
    tag_type = options[:tag_type]    
    fandoms = TagSetAssociation.get_search_terms(options[:fandom])
    tag_sets = TagSetAssociation.get_search_terms(options[:tag_set])

    combo_key = "autocomplete_association_combo_#{tag_type}_#{tag_sets.join('_')}_#{fandoms.join('_')}"

    # get the union of the wrangled fandom and the associations from the various tag sets
    keys_to_lookup = tag_sets.map {|set| fandoms.map {|fandom| "autocomplete_association_#{tag_type}_#{set}_#{fandom}"}}.flatten
    if options[:include_wrangled] == "true"
      keys_to_lookup += fandoms.map {|fandom| "autocomplete_fandom_#{fandom}_#{tag_type}"}.flatten
    end
    
    Rails.logger.info "!*!*!*!!! Looking up #{keys_to_lookup.join(', ')}"
    
    $redis.zunionstore(combo_key, keys_to_lookup, :aggregate => :max)
    results = $redis.zrevrange(combo_key, 0, -1)
    # expire fast
    $redis.expire combo_key, 1
    
    unless search_param.blank?
      search_regex = Tag.get_search_regex(search_param)
      results.select! {|tag| tag.match(search_regex)}
    end
    return results
  end

end
