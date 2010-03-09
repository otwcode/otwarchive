class GiftExchange < ActiveRecord::Base
  belongs_to :collection
  has_one :collection, :as => :challenge 
  
  # limits the kind of prompts users can submit 
  belongs_to :prompt_restriction, :class_name => "PromptRestriction", :dependent => :destroy  
  accepts_nested_attributes_for :prompt_restriction

  belongs_to :request_restriction, :class_name => "PromptRestriction", :dependent => :destroy  
  accepts_nested_attributes_for :request_restriction

  belongs_to :offer_restriction, :class_name => "PromptRestriction", :dependent => :destroy
  accepts_nested_attributes_for :offer_restriction

  validates_length_of :signup_instructions_general, :signup_instructions_requests, :signup_instructions_offers, { 
    :allow_blank => true,
    :maximum => ArchiveConfig.INFO_MAX, :too_long => t('gift_exchange.instructions_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.INFO_MAX)
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
      self.request_restriction.tag_set.save
      self.request_restriction.save
    end
  end

  def user_allowed_to_see_signups?(user)
    self.collection.user_is_maintainer?(user)
  end

  def user_allowed_to_sign_up?(user)
    self.collection.user_is_maintainer?(user) || 
      (self.signup_open && (!self.collection.moderated? || self.collection.user_is_posting_participant?(user)))
  end

end
