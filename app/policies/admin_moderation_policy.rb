class AdminModerationPolicy < ApplicationPolicy
  CONTENT_MODERATORS = %w(superadmin policy_and_abuse).freeze

  def self.can_edit_works?(user)
    self.new(user, nil).can_moderate_content?
  end

  def can_moderate_content?
    user_has_roles?(CONTENT_MODERATORS)
  end

  alias_method :hide?, :can_moderate_content?
  alias_method :set_spam?, :can_moderate_content?
  alias_method :destroy?, :can_moderate_content?
end
