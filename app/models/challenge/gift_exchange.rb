class GiftExchange < ActiveRecord::Base
  belongs_to :collection
  has_one :collection, :as => :challenge 

  attr_protected :signup_instructions_general_sanitizer_version
  attr_protected :signup_instructions_requests_sanitizer_version
  attr_protected :signup_instructions_offers_sanitizer_version

  #FIXME hack because time zones are being html encoded. couldn't figure out why.
  before_save :fix_time_zone
  def fix_time_zone
    return true if self.time_zone.nil?
    return true if ActiveSupport::TimeZone[self.time_zone]
    try = self.time_zone.gsub('&amp;', '&')
    self.time_zone = try if ActiveSupport::TimeZone[try]
  end

  
  # limits the kind of prompts users can submit 
  belongs_to :prompt_restriction, :class_name => "PromptRestriction", :dependent => :destroy  
  accepts_nested_attributes_for :prompt_restriction

  belongs_to :request_restriction, :class_name => "PromptRestriction", :dependent => :destroy  
  accepts_nested_attributes_for :request_restriction

  belongs_to :offer_restriction, :class_name => "PromptRestriction", :dependent => :destroy
  accepts_nested_attributes_for :offer_restriction

  belongs_to :potential_match_settings, :dependent => :destroy
  accepts_nested_attributes_for :potential_match_settings

  validates_length_of :signup_instructions_general, :signup_instructions_requests, :signup_instructions_offers, { 
    :allow_blank => true,
    :maximum => ArchiveConfig.INFO_MAX, :too_long => t('gift_exchange.instructions_too_long', :default => "must be less than %{max} letters long.", :max => ArchiveConfig.INFO_MAX)
  }

  %w(requests_num_required offers_num_required requests_num_allowed offers_num_allowed).each do |prompt_limit_field|
      validates_numericality_of prompt_limit_field, :only_integer => true, :less_than_or_equal_to => ArchiveConfig.PROMPTS_MAX, :greater_than_or_equal_to => 0
  end

  before_validation :update_allowed_values
  def update_allowed_values
    %w(request offer).each do |prompt_type|
      required = eval("#{prompt_type}s_num_required")
      allowed = eval("#{prompt_type}s_num_allowed")
      if required > allowed
        eval("#{prompt_type}s_num_allowed = required")
      end
    end
  end

  after_save :copy_tag_set_from_offer_to_request
  def copy_tag_set_from_offer_to_request
    if self.offer_restriction && self.offer_restriction.tag_set
      self.request_restriction.build_tag_set unless self.request_restriction.tag_set
      self.request_restriction.tag_set.tags = self.offer_restriction.tag_set.tags
      self.request_restriction.character_restrict_to_fandom = self.offer_restriction.character_restrict_to_fandom
      self.request_restriction.relationship_restrict_to_fandom = self.offer_restriction.relationship_restrict_to_fandom      
      self.request_restriction.tag_set.save
      self.request_restriction.save
    end
  end
  
  def topmost_tag_type
    topmost_type = ""
    TagSet::TAG_TYPES.each do |tag_type| 
      if self.request_restriction.send("#{tag_type}_num_allowed") > 0 
        topmost_type = tag_type
        break
      end
    end
    topmost_type
  end

  def user_allowed_to_see_signups?(user)
    self.collection.user_is_maintainer?(user)
  end
  
  def user_allowed_to_see_requests_summary?(user)
    self.collection.user_is_maintainer?(user) || self.requests_summary_visible?
  end

  def user_allowed_to_see_assignments?(user)
    self.collection.user_is_maintainer?(user)
  end

  def user_allowed_to_sign_up?(user)
    self.collection.user_is_maintainer?(user) || 
      (self.signup_open && (!self.collection.moderated? || self.collection.user_is_posting_participant?(user)))
  end

end
