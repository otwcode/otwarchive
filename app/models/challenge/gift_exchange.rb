class GiftExchange < ActiveRecord::Base
  belongs_to :collection
  has_one :collection, :as => :challenge 

  # limits the kind of prompts users can submit 
  belongs_to :request_restriction, :class_name => "PromptRestriction", :dependent => :destroy  
  accepts_nested_attributes_for :request_restriction

  belongs_to :offer_restriction, :class_name => "PromptRestriction", :dependent => :destroy
  accepts_nested_attributes_for :offer_restriction


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

  def user_allowed_to_see_signups?(user)
    self.collection.user_is_maintainer?(user)
  end

  def user_allowed_to_sign_up?(user)
    self.collection.user_is_maintainer?(user) || 
      (self.signup_open && (!self.collection.moderated? || self.collection.user_is_posting_participant?(user)))
  end

end
