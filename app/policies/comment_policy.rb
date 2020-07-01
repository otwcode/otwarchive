class CommentPolicy < ApplicationPolicy
  DELETE_COMMENT_ROLES = %w(superadmin policy_and_abuse communications support).freeze

  def self.can_delete_comment?(user)
    self.new(user, nil).can_delete_comment?
  end
    
  def can_delete_comment?
    user_has_roles?(DELETE_COMMENT_ROLES)
  end

  def can_mark_comment_spam?
    (can_delete_comment? || author_of?(record.ultimate_parent))
  end

  def can_mark_comment_ham?
    can_delete_comment?
  end

  alias_method :destroy?, :can_delete_comment?
  alias_method :approve?, :can_mark_comment_ham?
  alias_method :reject?, :can_mark_comment_spam?

  private

  def author_of?(work)
    user.is_a?(User) && user.is_author_of?(work)
  end
end
