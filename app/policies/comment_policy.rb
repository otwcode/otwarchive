class CommentPolicy < ApplicationPolicy
  DESTROY_ROLES = %w[superadmin board policy_and_abuse communications support].freeze
  SPAM_ROLES = %w[superadmin board policy_and_abuse communications support].freeze

  def can_destroy_comment?
    user_has_roles?(DESTROY_ROLES)
  end

  def can_mark_comment_spam?
    user_has_roles?(SPAM_ROLES)
  end

  alias destroy? can_destroy_comment?
  alias approve? can_mark_comment_spam?
  alias reject? can_mark_comment_spam?
end
