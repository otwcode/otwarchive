class AdminPostPolicy < ApplicationPolicy
  POSTING_ROLES = %w(superadmin communications translation).freeze

  def self.can_post?(user)
    self.new(user, nil).can_post?
  end

  def can_post?
    user_has_roles?(POSTING_ROLES)
  end

  alias new? can_post?
  alias edit? can_post?
  alias create? can_post?
  alias update? can_post?
  alias destroy? can_post?
end
