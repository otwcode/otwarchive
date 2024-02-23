class CommentPolicy < ApplicationPolicy
  DESTROY_COMMENT_ROLES = %w[superadmin board policy_and_abuse support].freeze
  DESTROY_ADMIN_POST_COMMENT_ROLES = %w[superadmin board board_assistants_team communications elections policy_and_abuse support].freeze
  FREEZE_TAG_COMMENT_ROLES = %w[superadmin tag_wrangling].freeze
  FREEZE_WORK_COMMENT_ROLES = %w[superadmin policy_and_abuse].freeze
  HIDE_TAG_COMMENT_ROLES = %w[superadmin tag_wrangling].freeze
  HIDE_WORK_COMMENT_ROLES = %w[superadmin policy_and_abuse].freeze
  SPAM_ADMIN_POST_COMMENT_ROLES = %w[superadmin board board_assistants_team communications elections policy_and_abuse support].freeze
  SPAM_WORK_COMMENT_ROLES = %w[superadmin board policy_and_abuse support].freeze

  def can_destroy_comment?
    case record.ultimate_parent
    when AdminPost
      user_has_roles?(DESTROY_ADMIN_POST_COMMENT_ROLES)
    else
      user_has_roles?(DESTROY_COMMENT_ROLES)
    end
  end

  def can_freeze_comment?
    case record.ultimate_parent
    when AdminPost
      user&.is_a?(Admin)
    when Tag
      user_has_roles?(FREEZE_TAG_COMMENT_ROLES)
    when Work
      user_has_roles?(FREEZE_WORK_COMMENT_ROLES)
    end
  end

  def can_hide_comment?
    case record.ultimate_parent
    when AdminPost
      user&.is_a?(Admin)
    when Tag
      user_has_roles?(HIDE_TAG_COMMENT_ROLES)
    when Work
      user_has_roles?(HIDE_WORK_COMMENT_ROLES)
    end
  end

  def can_mark_comment_spam?
    case record.ultimate_parent
    when AdminPost
      user_has_roles?(SPAM_ADMIN_POST_COMMENT_ROLES)
    when Work
      user_has_roles?(SPAM_WORK_COMMENT_ROLES)
    end
  end

  alias destroy? can_destroy_comment?
  alias approve? can_mark_comment_spam?
  alias reject? can_mark_comment_spam?

  def show_email?
    user_has_roles?(%w[policy_and_abuse support superadmin])
  end
end
