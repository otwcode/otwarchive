class AdminPostPolicy < ApplicationPolicy
  POSTING_ROLES = %w[superadmin board board_assistants_team communications support translation].freeze
  DRAFTING_ROLES = %w[policy_and_abuse].freeze

  def can_post?
    user_has_roles?(POSTING_ROLES)
  end

  def can_draft?
    user_has_roles?(DRAFTING_ROLES) || can_post?
  end

  def edit?
    can_post? || (@record&.draft? && can_draft?)
  end

  alias new? can_draft?
  alias show? can_draft?
  alias create? edit?
  alias update? edit?
  alias destroy? edit?
  alias post? can_post?
  alias drafts? can_draft?
  alias preview? edit?
end
