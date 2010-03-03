class PromptRestriction < ActiveRecord::Base
  belongs_to :tag_set, :dependent => :destroy
  accepts_nested_attributes_for :tag_set

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
  
  before_validation :update_allowed_values
  def update_allowed_values
    %w(fandom character pairing rating category freeform warning).each do |tag_type|
      required = eval("#{tag_type}_num_required")
      allowed = eval("#{tag_type}_num_allowed")
      if required > allowed
        eval("#{tag_type}_num_allowed = required")
      end
    end
  end
  
  def has_tags_of_type?(type)
    tag_set && !tag_set.with_type(type.classify).empty?
  end
  
  def tags_of_type(type)
    tag_set.with_type(type.classify)
  end
  
end
