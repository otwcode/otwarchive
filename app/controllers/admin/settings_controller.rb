class Admin::SettingsController < ApplicationController
  before_filter :admin_only

  def index
    @admin_setting = AdminSetting.first || AdminSetting.create(:last_updated_by => Admin.first)
  end

  # PUT /admin_settings/1
  # PUT /admin_settings/1.xml
  def update
    @admin_setting = AdminSetting.first || AdminSetting.create(:last_updated_by => Admin.first)

    if @admin_setting.update_attributes(admin_setting_params)
      flash[:notice] = ts("Archive settings were successfully updated.")
      redirect_to admin_settings_path
    else
      render :action => "index"
    end
  end

  private
  def admin_setting_params
    params.require(:admin_setting).permit(
      :account_creation_enabled, :invite_from_queue_enabled, :invite_from_queue_number,
      :invite_from_queue_frequency, :days_to_purge_unactivated, :last_updated_by,
      :invite_from_queue_at, :suspend_filter_counts, :suspend_filter_counts_at,
      :enable_test_caching, :cache_expiration, :tag_wrangling_off, :guest_downloading_off,
      :disable_filtering, :request_invite_enabled, :creation_requires_invite
    )
  end
end
