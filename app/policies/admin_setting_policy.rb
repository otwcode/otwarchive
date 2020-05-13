class AdminSettingPolicy < ApplicationPolicy
  SETTINGS_ROLES = %w(superadmin support tag_wrangling policy_and_abuse).freeze

  def self.user_has_correct_role?(user, role)
    self.new(user, nil).user_has_correct_role?(role)
  end

  def user_has_correct_role?(role)
    user_has_roles?([role]) || user.roles.include?('superadmin')
  end

  def self.can_update_settings?(user)
    self.new(user, nil).can_update_settings?
  end

  def can_update_settings?
    user_has_roles?(SETTINGS_ROLES)
  end

  def permitted_attributes
    permitted = []
    if user.roles.include?('superadmin')
      permitted = [
        :account_creation_enabled, :invite_from_queue_enabled, :invite_from_queue_number,
        :invite_from_queue_frequency, :days_to_purge_unactivated,
        :invite_from_queue_at, :suspend_filter_counts, :suspend_filter_counts_at,
        :enable_test_caching, :cache_expiration, :tag_wrangling_off,
        :request_invite_enabled, :creation_requires_invite, :downloads_enabled,
        :hide_spam, :disable_support_form, :disabled_support_form_text
      ]
    else
      permitted = permitted + [:tag_wrangling_off] if user.roles.include?('tag_wrangling')
      permitted = permitted + [:disable_support_form, :disabled_support_form_text] if user.roles.include?('support')
      permitted = permitted + [:hide_spam] if user.roles.include?('policy_and_abuse')
    end

    permitted
  end

  def verify_permitted_params(setting_params)
    setting_params = setting_params.keys.map(&:to_sym) - [:last_updated_by]
    unauthorized_params = setting_params - permitted_attributes

    if unauthorized_params.any?
      extra_params = unauthorized_params.map{ |p| p.to_s.humanize }.join(", ")
      "You are not permitted to change the following settings: #{extra_params}"
    else
      true
    end
  end

  alias_method :index?, :can_update_settings?
  alias_method :update?, :can_update_settings?
end
