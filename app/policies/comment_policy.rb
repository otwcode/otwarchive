class CommentPolicy < ApplicationPolicy
  DESTROY_COMMENT_ROLES = %w[superadmin board legal policy_and_abuse support].freeze
  DESTROY_ADMIN_POST_COMMENT_ROLES = %w[superadmin board board_assistants_team communications elections legal policy_and_abuse support].freeze
  FREEZE_TAG_COMMENT_ROLES = %w[superadmin tag_wrangling].freeze
  FREEZE_WORK_COMMENT_ROLES = %w[superadmin policy_and_abuse].freeze
  HIDE_TAG_COMMENT_ROLES = %w[superadmin legal tag_wrangling].freeze
  HIDE_WORK_COMMENT_ROLES = %w[superadmin legal policy_and_abuse].freeze
  SPAM_ADMIN_POST_COMMENT_ROLES = %w[superadmin board board_assistants_team communications elections policy_and_abuse support].freeze
  SPAM_COMMENT_ROLES = %w[superadmin board policy_and_abuse support].freeze

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
    else
      user_has_roles?(SPAM_COMMENT_ROLES)
    end
  end

  def can_review_comment?
    record.ultimate_parent.is_a?(AdminPost) && user&.is_a?(Admin)
  end

  def can_review_all?
    record.is_a?(AdminPost) && user&.is_a?(Admin)
  end

  alias destroy? can_destroy_comment?
  alias approve? can_mark_comment_spam?
  alias reject? can_mark_comment_spam?
  alias review? can_review_comment?
  alias review_all? can_review_all?

  def show_email?
    user_has_roles?(%w[legal policy_and_abuse support superadmin])
  end
end
