class AdminPostPolicy < ApplicationPolicy
  POSTING_ROLES = %w(superadmin communications translation).freeze

  def self.can_post?(user)
    self.new(user, nil).can_post?
  end

  def can_post?
    user_has_roles?(POSTING_ROLES)
  end

  alias_method :new?, :can_post?
  alias_method :edit?, :can_post?
  alias_method :create?, :can_post?
  alias_method :update?, :can_post?
  alias_method :destroy?, :can_post?
end
