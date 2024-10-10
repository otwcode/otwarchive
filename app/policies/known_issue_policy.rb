# frozen_string_literal: true

class KnownIssuePolicy < ApplicationPolicy
  MANAGE_ROLES = %w[superadmin support].freeze

  def admin_index?
    user_has_roles?(MANAGE_ROLES)
  end

  alias destroy? admin_index?
  alias edit? admin_index?
  alias create? admin_index?
  alias new? admin_index?
  alias show? admin_index?
  alias update? admin_index?
end
