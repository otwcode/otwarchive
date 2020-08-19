class CommentPolicy < ApplicationPolicy
  DESTROY_ROLES = %w[superadmin board policy_and_abuse communications support].freeze
  FREEZE_TAG_COMMENT_ROLES = %w[superadmin tag_wrangling].freeze
  FREEZE_WORK_COMMENT_ROLES = %w[superadmin policy_and_abuse].freeze
  SPAM_ROLES = %w[superadmin board policy_and_abuse communications support].freeze

  def can_destroy_comment?
    user_has_roles?(DESTROY_ROLES)
  end

  def can_freeze_work_comment?
    user_has_roles?(FREEZE_WORK_COMMENT_ROLES)
  end

  def can_freeze_tag_comment?
    user_has_roles?(FREEZE_TAG_COMMENT_ROLES)
  end

  def can_mark_comment_spam?
    user_has_roles?(SPAM_ROLES)
  end

  alias destroy? can_destroy_comment?
  alias approve? can_mark_comment_spam?
  alias reject? can_mark_comment_spam?
end
