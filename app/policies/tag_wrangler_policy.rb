class TagWranglerPolicy < ApplicationPolicy
  WRANGLING_REPORT = %w[superadmin tag_wrangling].freeze

  def report_csv?
    user_has_roles?(WRANGLING_REPORT)
  end
end
