class PromptRestriction < ActiveRecord::Base
  belongs_to :tag_set, :dependent => :destroy
  accepts_nested_attributes_for :tag_set, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  # note: there is no has_one/has_many association here because this class may or may not 
  # be used by many different challenge classes. For convenience, if you use this class in
  # a challenge class, add that challenge class to this list so other coders can see where
  # it is used and how it behaves:
  #
  # challenge/gift_exchange
  #

  # VALIDATION
  %w(fandom_num_required category_num_required rating_num_required character_num_required 
    pairing_num_required freeform_num_required warning_num_required 
    fandom_num_allowed category_num_allowed rating_num_allowed character_num_allowed 
    pairing_num_allowed freeform_num_allowed warning_num_allowed).each do |tag_limit_field|
      validates_numericality_of tag_limit_field, :only_integer => true, :less_than_or_equal_to => ArchiveConfig.PROMPT_TAGS_MAX, :greater_than_or_equal_to => 0
  end
  
  # check that we don't have a single tag of any kind in the tag set
  validate :no_single_specified_tags
  def no_single_specified_tags
    error_types = []
    TagSet::TAG_TYPES.each do |tag_type|
      if tags_of_type(tag_type).count == 1
        error_types << tag_type
      end
    end
    unless error_types.empty?
      errors.add_to_base(t('prompt_restriction.single_tag', 
        :default => "You haven't given users a choice of {{error_types}}. (If that is deliberate, just set the number of tags required and allowed for that type to 0 instead.)", 
        :error_types => error_types.join(ArchiveConfig.DELIMITER_FOR_OUTPUT)))
    end
  end
  
  before_validation :update_allowed_values
  # if anything is required make sure it is also allowed
  def update_allowed_values
    debugger
    self.url_allowed = true if url_required
    self.description_allowed = true if description_required

    TagSet::TAG_TYPES.each do |tag_type|
      required = eval("#{tag_type}_num_required") || eval("self.#{tag_type}_num_required") || 0
      allowed = eval("#{tag_type}_num_allowed") || eval("self.#{tag_type}_num_allowed") || 0
      if required > allowed
        eval("self.#{tag_type}_num_allowed = required")
      end
    end
  end
  
  def has_tags_of_type?(type)
    tag_set && !tag_set.with_type(type.classify).empty?
  end
  
  def tags_of_type(type)
    self.tag_set ? tag_set.with_type(type.classify) : []
  end
  
end
