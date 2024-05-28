class GiftExchange < ApplicationRecord
  PROMPT_TYPES = %w[requests offers].freeze
  include ChallengeCore

  override_datetime_setters

  belongs_to :collection
  has_one :collection, as: :challenge

  # limits the kind of prompts users can submit
  belongs_to :request_restriction, class_name: "PromptRestriction", dependent: :destroy
  accepts_nested_attributes_for :request_restriction

  belongs_to :offer_restriction, class_name: "PromptRestriction", dependent: :destroy
  accepts_nested_attributes_for :offer_restriction

  belongs_to :potential_match_settings, dependent: :destroy
  accepts_nested_attributes_for :potential_match_settings

  validates :signup_instructions_general, :signup_instructions_requests, :signup_instructions_offers, length: {
    allow_blank: true,
    maximum: ArchiveConfig.INFO_MAX, too_long: ts("must be less than %{max} letters long.", max: ArchiveConfig.INFO_MAX)
  }

  PROMPT_TYPES.each do |type|
    %w[required allowed].each do |setting|
      prompt_limit_field = "#{type}_num_#{setting}"
      validates prompt_limit_field, numericality: {
        only_integer: true,
        less_than_or_equal_to: ArchiveConfig.PROMPTS_MAX,
        greater_than_or_equal_to: 1
      }
    end
  end

  before_validation :update_allowed_values
  def update_allowed_values
    %w[request offer].each do |prompt_type|
      required = send("#{prompt_type}s_num_required")
      allowed = send("#{prompt_type}s_num_allowed")
      send("#{prompt_type}s_num_allowed=", required) if required > allowed
    end
  end

  # make sure that challenge sign-up / close / open dates aren't contradictory
  validate :validate_signup_dates

  #  When Challenges are deleted, there are two references left behind that need to be reset to nil
  before_destroy :clear_challenge_references

  after_save :copy_tag_set_from_offer_to_request
  def copy_tag_set_from_offer_to_request
    return unless self.offer_restriction

    self.request_restriction.set_owned_tag_sets(self.offer_restriction.owned_tag_sets)

    # copy the tag-set-based restriction settings
    self.request_restriction.character_restrict_to_fandom = self.offer_restriction.character_restrict_to_fandom
    self.request_restriction.relationship_restrict_to_fandom = self.offer_restriction.relationship_restrict_to_fandom
    self.request_restriction.character_restrict_to_tag_set = self.offer_restriction.character_restrict_to_tag_set
    self.request_restriction.relationship_restrict_to_tag_set = self.offer_restriction.relationship_restrict_to_tag_set
    self.request_restriction.save
  end

  # override core
  def allow_name_change?
    false
  end

  def topmost_tag_type
    self.request_restriction.topmost_tag_type
  end

  def user_allowed_to_see_requests_summary?(user)
    self.collection.user_is_maintainer?(user) || self.requests_summary_visible?
  end

  def user_allowed_to_see_prompt?(user, prompt)
    self.collection.user_is_maintainer?(user) || prompt.pseud.user == user
  end
end
