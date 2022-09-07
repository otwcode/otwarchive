class UserCreationPolicy < ApplicationPolicy
  # Defines the roles that allow admins to modify user creations.
  # User creations are Bookmarks, ExternalWorks, Series, Works.
  DESTROY_ROLES = %w[superadmin policy_and_abuse].freeze
  # Support admins need edit permissions due to AO3-4932.
  EDIT_ROLES = %w[superadmin support policy_and_abuse].freeze
  HIDE_ROLES = %w[superadmin policy_and_abuse].freeze
  SPAM_ROLES = %w[superadmin policy_and_abuse].freeze

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

  # Currently applies to editing ExternalWorks and the tags or language of Works.
  # Admins cannot edit Bookmarks or Series or make any other type of edit to
  # Works.
  def can_edit_creations?
    user_has_roles?(EDIT_ROLES)
  end

  def can_hide_creations?
    user_has_roles?(HIDE_ROLES)
  end

  # Currently applies to Works.
  def can_mark_creations_spam?
    user_has_roles?(SPAM_ROLES)
  end

  # ExternalWorksController
  alias edit? can_edit_creations?
  # Admin::UserCreationsController
  alias hide? can_hide_creations?
  alias set_spam? can_mark_creations_spam?
  alias destroy? can_destroy_creations?

  def show_ip_address?
    user_has_roles?(%w[superadmin policy_and_abuse])
  end
end
