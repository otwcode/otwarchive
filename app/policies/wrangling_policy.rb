# frozen_string_literal: true

class WranglingPolicy < ApplicationPolicy
  FULL_ACCESS_ROLES = %w[superadmin tag_wrangling].freeze
  VIEW_ACCESS_ROLES = (FULL_ACCESS_ROLES + %w[policy_and_abuse]).freeze

  def full_access?
    user_has_roles?(FULL_ACCESS_ROLES)
  end

  def view_access?
    user_has_roles?(VIEW_ACCESS_ROLES)
  end

  alias create? full_access?
  alias destroy? full_access?
  alias index? view_access?
  alias mass_update? full_access?
  alias show? full_access?
  alias report_csv? full_access?
end
