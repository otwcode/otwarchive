class CommentPolicy < ApplicationPolicy
  DESTROY_ROLES = %w(superadmin policy_and_abuse communications support).freeze
  SPAM_ROLES = %w(superadmin policy_and_abuse communications support).freeze

  def self.can_destroy_comment?(user)
    self.new(user, nil).can_destroy_comment?
  end
    
  def self.can_mark_comment_spam?(user)
    self.new(user, nil).can_mark_comment_spam?
  end

  def can_destroy_comment?
    user_has_roles?(DESTROY_ROLES)
  end

  def can_mark_comment_spam?
    user_has_roles?(SPAM_ROLES)
  end

  alias_method :destroy?, :can_destroy_comment?
  alias_method :approve?, :can_mark_comment_spam?
  alias_method :reject?, :can_mark_comment_spam?
end
