class SpamPolicy < ApplicationPolicy
  MANAGE_SPAM = %w[superadmin policy_and_abuse].freeze

  def index?
    user_has_roles?(MANAGE_SPAM)
  end

  alias bulk_update? index?

end
