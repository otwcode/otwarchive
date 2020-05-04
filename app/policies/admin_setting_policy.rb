class AdminSettingPolicy < ApplicationPolicy
  SETTINGS_ROLES = %w(superadmin tag_wrangling).freeze

  def index?
    update?
  end

  def update?
    user_has_roles?(SETTINGS_ROLES)
  end

  def permitted_attributes
    if user.roles.include?('superadmin')
      [
        :account_creation_enabled, :invite_from_queue_enabled, :invite_from_queue_number,
        :invite_from_queue_frequency, :days_to_purge_unactivated,
        :invite_from_queue_at, :suspend_filter_counts, :suspend_filter_counts_at,
        :enable_test_caching, :cache_expiration, :tag_wrangling_off,
        :request_invite_enabled, :creation_requires_invite, :downloads_enabled,
        :hide_spam, :disable_support_form, :disabled_support_form_text
      ]
    elsif user.roles.include?('tag_wrangling')
      [:tag_wrangling_off]
    end
  end
end
