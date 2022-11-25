class WranglingGuidelinePolicy < ApplicationPolicy
  MANAGE_WRANGLING_GUIDELINE = %w[superadmin tag_wrangling].freeze

  def new?
    user_has_roles?(MANAGE_WRANGLING_GUIDELINE)
  end

  alias edit? new?
  alias manage? new?
  alias create? new?
  alias update? new?
  alias destroy? new?
end