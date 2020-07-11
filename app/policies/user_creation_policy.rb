class UserCreationPolicy < ApplicationPolicy
  # Defines the roles that allow admins to modify user creations.
  # User creations are Bookmarks, ExternalWorks, Series, Works.
  DESTROY_ROLES = %w(superadmin policy_and_abuse).freeze
  EDIT_ROLES = %w(superadmin policy_and_abuse).freeze
  HIDE_ROLES = %w(superadmin policy_and_abuse).freeze
  SPAM_ROLES = %w(superadmin policy_and_abuse).freeze

  def self.can_destroy_creations?(user)
    self.new(user, nil).can_destroy_creations?
  end

  def self.can_edit_creations?(user)
    self.new(user, nil).can_edit_creations?
  end

  def self.can_hide_creations?(user)
    self.new(user, nil).can_hide_creations?
  end

  def self.can_mark_creations_spam?(user)
    self.new(user, nil).can_mark_creations_spam?
  end

  def can_destroy_creations?
    user_has_roles?(DESTROY_ROLES)
  end

  def can_edit_creations?
    user_has_roles?(EDIT_ROLES)
  end

  def can_hide_creations?
    user_has_roles?(HIDE_ROLES)
  end

  def can_mark_creations_spam?
    user_has_roles?(SPAM_ROLES)
  end

  alias_method :edit?, :can_edit_creations?
  alias_method :hide?, :can_hide_creations?
  alias_method :set_spam?, :can_mark_creations_spam?
  alias_method :destroy?, :can_destroy_creations?
end
