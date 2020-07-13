class AdminSettingPolicy < ApplicationPolicy
  # Defines the roles that allow admins to view all settings.
  SETTINGS_ROLES = %w(policy_and_abuse superadmin support tag_wrangling).freeze

  # Define which roles can update which settings.
  ALLOWED_SETTINGS_BY_ROLES = {
    "policy_and_abuse" => %i[hide_spam],
    "superadmin" => %i[
      account_creation_enabled
      cache_expiration
      creation_requires_invite
      days_to_purge_unactivated
      disable_support_form
      disabled_support_form_text
      downloads_enabled
      enable_test_caching
      hide_spam
      invite_from_queue_at
      invite_from_queue_enabled
      invite_from_queue_frequency
      invite_from_queue_number
      request_invite_enabled
      suspend_filter_counts
      suspend_filter_counts_at
      tag_wrangling_off
    ],
    "support" => %i[disable_support_form disabled_support_form_text],
    "tag_wrangling" => %i[tag_wrangling_off]
  }.freeze

  def can_view_settings?
    user_has_roles?(SETTINGS_ROLES)
  end

  def permitted_attributes
    ALLOWED_SETTINGS_BY_ROLES.values_at(*user.roles).compact.flatten
  end

  # By default, Pundit's helper discards any settings the current admin
  # cannot update (https://github.com/varvet/pundit/#strong-parameters).
  #
  # To display an error when the admin attempts to update settings they
  # shouldn't, we get the difference between the attempted settings
  # filtered by the superadmin role, and the attempted settings filtered
  # by the current admin's roles.
  def unpermitted_attributes(params)
    all_attributes = params.require(:admin_setting).permit(ALLOWED_SETTINGS_BY_ROLES["superadmin"]).keys
    all_attributes - permitted_attributes.map(&:to_s)
  end

  alias index? can_view_settings?
  alias update? can_view_settings?
end
