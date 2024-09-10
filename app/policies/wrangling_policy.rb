# frozen_string_literal: true

class WranglingPolicy < ApplicationPolicy
  FULL_ACCESS_ROLES = %w[superadmin tag_wrangling].freeze

  def full_access?
    user_has_roles?(FULL_ACCESS_ROLES)
  end

  alias create? full_access?
  alias destroy? full_access?
  alias show? full_access?
  alias report_csv? full_access?
end
