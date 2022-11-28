class UserCreationPolicy < ApplicationPolicy
  # User creations are Bookmarks, ExternalWorks, Series, Works.

  # Roles that allow destroying all types of user creations.
  DESTROY_ROLES = %w[superadmin policy_and_abuse].freeze

  # Roles that allow destroying only Works.
  #
  # Include support admins for handling duplicate works.
  DESTROY_WORK_ROLES = %w[support].freeze

  # Roles that allow editing user creations, specifically:
  # - ExternalWorks
  # - Works (only tags and language)
  #
  # Admins cannot edit Bookmarks or Series or make any other changes to Works.
  #
  # Include support admins due to AO3-4932.
  EDIT_ROLES = %w[superadmin policy_and_abuse support].freeze

  HIDE_ROLES = %w[superadmin policy_and_abuse].freeze

  # Currently applies to Works.
  SPAM_ROLES = %w[superadmin policy_and_abuse].freeze

  def can_destroy_creations?
    user_has_roles?(DESTROY_ROLES) || user_has_roles?(DESTROY_WORK_ROLES) && record.class == Work
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
