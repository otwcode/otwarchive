class AdminModerationPolicy < ApplicationPolicy
  CONTENT_MODERATORS = %w(superadmin policy_and_abuse).freeze
  COMMENT_MODERATORS = %w(superadmin policy_and_abuse communications support).freeze

  def self.can_edit_works?(user)
    self.new(user, nil).can_moderate_content?
  end

  def hide?
    can_moderate_record?
  end

  def set_spam?
    can_moderate_record?
  end

  def destroy?
    can_moderate_record?
  end

  def edit?
    can_moderate_content?
  end

  def can_moderate_record?
    record.is_a?(Comment) ? can_moderate_comment? : can_moderate_content?
  end

  def can_moderate_content?
    user_has_roles?(CONTENT_MODERATORS)
  end

  def can_moderate_comments?
    user_has_roles?(COMMENT_MODERATORS)
  end
end
