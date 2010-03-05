class TagSet < ActiveRecord::Base
  
  TAG_TYPES = %w(fandom character pairing freeform category rating warning)
  
  has_many :set_taggings, :dependent => :destroy
  has_many :tags, :through => :set_taggings

  has_one :prompt
  
  # validates_tag_canonicity_of :fandom_tagnames, :character_tagnames, 
  #   :pairing_tagnames, :rating_tagnames, :warning_tagnames, :category_tagnames, :freeform_tagnames

  validate :all_tags_must_be_canonical  
  def all_tags_must_be_canonical
    uncanonical_tags = self.tags.reject {|tag| tag.canonical}
    unless uncanonical_tags.empty?
      errors.add_to_base(t('tag_set.must_be_canonical', 
                :default => "The following tags aren't canonical and can't be used: {{taglist}}", 
                :taglist => uncanonical_tags.collect(&:name).join(", ") ))
    end
  end
  
  validate :correct_number_of_tags
  def correct_number_of_tags
    if prompt && (restriction = prompt.get_prompt_restriction)
      errors_to_add = []
      # we have limits this tag set needs to match
      # make sure prompt has no more/less than the required/allowed number of tags of each type
      TAG_TYPES.each do |tag_type|
        required = eval("restriction.#{tag_type}_num_required")
        allowed = eval("restriction.#{tag_type}_num_allowed")
        prompt_type = prompt.offer ? 'Offer' : 'Request'
        taglist = tags.with_type(tag_type)
        tag_count = taglist.count
        taglist_string = taglist.empty? ?  t('prompt.taglist_none', :default => "none") : taglist.collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
        unless tag_count.between?(required, allowed)
          if allowed == 0
            errors_to_add << t("prompt.#{prompt_type}_#{tag_type}_not_allowed", 
              :default => "#{prompt_type} cannot include any #{tag_type} tags. You currently have: {{taglist}}.", 
              :taglist => taglist_string)
          elsif required == allowed
            errors_to_add << t("prompt.#{prompt_type}_#{tag_type}_mismatch", 
              :default => "#{prompt_type} must have exactly {{required}} #{tag_type} tags. You currently have {{count}}: {{taglist}}.", 
              :required => required, :count => tag_count, :taglist => taglist_string)
          else
            errors_to_add << t("prompt.#{prompt_type}_#{tag_type}_range_mismatch", 
              :default => "#{prompt_type} must have between {{required}} and {{allowed}} #{tag_type} tags. You currently have {{count}}: {{taglist}}.",
              :required => required, :allowed => allowed, :count => tag_count, :taglist => taglist_string)
          end
        end
      end
      
      unless errors_to_add.empty?
        # yuuuuuck :( but so much less ugly than define-method'ing these all
        self.errors.add_to_base(errors_to_add.join("</li><li>"))
      end
    end
  end

  named_scope :matching, lambda {|tag_set_to_match|
    {
      :select => "DISTINCT tag_sets.*",
      :joins => :tags,
      :group => 'tag_sets.id',
      :conditions => ["tag_sets.id != ? AND tags.id in (?)", tag_set_to_match.id, tag_set_to_match.tags],
      :order => "count(tags.id) desc"
    }
  }
  
  def has_tag?(tag)
    self.tags.include?(tag)
  end

  # this code defines the functions fandom_tagnames=/fandom_tagnames, character_tagnames=... etc
  # to set the tags by separate type`
  # because all of these are the same, I'm using define_method to avoid creating a
  # ton of almost duplicate functions
  TAG_TYPES.each do |type|
    define_method("#{type}_tagnames=") do |taglist|
      taglist = (taglist.kind_of?(String) ? taglist.split(ArchiveConfig.DELIMITER_FOR_INPUT) : taglist)
      new_tags = taglist.reject {|tagname| tagname.blank? }.map {|tagname| (type.classify.constantize).find_or_create_by_name(tagname.squish)}
      old_tags = self.with_type(type.classify)
      tags_to_set = (self.tags - old_tags + new_tags).compact.uniq
      self.tags = tags_to_set
    end
    
    define_method("#{type}_tagnames") do
      self.with_type(type.classify).collect(&:name).join(ArchiveConfig.DELIMITER_FOR_OUTPUT).sort
    end    
  end
  
  def with_type(type)
    return self.tags.with_type(type)
  end

  def empty?
    self.tags.empty?
  end
  
  def exact_match?(another)
    self.tags == another.tags
  end
    
  def no_match?(another)
    (self.tags & another.tags).empty? && !self.tags.empty?
  end
  
  def partial_match?(another)
    !(self.tags & another.tags).empty?
  end
  
  def is_subset_of?(another, type=nil)
    if type
      (self.tags.with_type(type) & another.tags.with_type(type)) == self.tags.with_type(type)
    else
      (self.tags & another.tags) == self.tags
    end
  end
  
  def is_superset_of?(another, type=nil)
    if type
      (self.tags.with_type(type) & another.tags.with_type(type)) == another.tags.with_type(type)
    else
      (self.tags & another.tags) == another.tags
    end
  end

  def match_with_type?(another, type)
    (self.tags.with_type(type) & another.tags.with_type(type)) == self.tags.with_type(type)
  end
  
  def partial_match_with_type?(another, type)
    !(self.tags.with_type(type) & another.tags.with_type(type)).empty?
  end
  
  def matching_tags(another)
    self.tags & another.tags
  end
  
  def matching_tags_with_type(another)
    self.tags.with_type(type) & another.tags.with_type(type)
  end
  
end
