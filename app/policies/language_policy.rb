class LanguagePolicy < ApplicationPolicy
  LANGUAGE_EDIT_ACCESS = %w[superadmin translation support policy_and_abuse].freeze
  LANGUAGE_CREATE_ACCESS = %w[superadmin translation].freeze

  def new?
    user_has_roles?(LANGUAGE_CREATE_ACCESS)
  end

  def edit?
    user_has_roles?(LANGUAGE_EDIT_ACCESS)
  end

  def can_edit_abuse_support_available?
    user_has_roles?(%w[superadmin translation policy_and_abuse])
  end

  def can_edit_other_fields?
    user_has_roles?(%w[superadmin translation support])
  end

  alias create? new?
  alias update? edit?
end
