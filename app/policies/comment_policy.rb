class CommentPolicy < ApplicationPolicy
  DELETE_COMMENT_ROLES = %w(superadmin policy_and_abuse communications support).freeze

  def self.can_delete_comment?(user)
    self.new(user, nil).can_delete_comment?
  end
    
  def can_delete_comment?
    user_has_roles?(DELETE_COMMENT_ROLES)
  end

  alias_method :destroy?, :can_delete_comment?
  alias_method :approve?, :can_delete_comment?
  alias_method :reject?, :can_delete_comment?
end
