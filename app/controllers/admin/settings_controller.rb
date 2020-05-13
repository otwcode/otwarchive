class Admin::SettingsController < Admin::BaseController
  def index
    @admin_setting = AdminSetting.first || AdminSetting.create(last_updated_by: Admin.first)
    authorize @admin_setting
  end

  # PUT /admin_settings/1
  # PUT /admin_settings/1.xml
  def update
    @admin_setting = AdminSetting.first || AdminSetting.create(last_updated_by: Admin.first)
    authorize @admin_setting
    authorized_params = policy(@admin_setting).verify_permitted_params(admin_setting_params)

    if authorized_params == true && @admin_setting.update(admin_setting_params)
      flash[:notice] = ts("Archive settings were successfully updated.")
      redirect_to admin_settings_path
    else
      flash[:error] = authorized_params unless authorized_params == true 
      render action: "index"
    end
  end

  private

  def admin_setting_params
    params.require(:admin_setting).permit(
      :account_creation_enabled, :invite_from_queue_enabled, :invite_from_queue_number,
      :invite_from_queue_frequency, :days_to_purge_unactivated,
      :invite_from_queue_at, :suspend_filter_counts, :suspend_filter_counts_at,
      :enable_test_caching, :cache_expiration, :tag_wrangling_off,
      :request_invite_enabled, :creation_requires_invite, :downloads_enabled,
      :hide_spam, :disable_support_form, :disabled_support_form_text
    ).merge(last_updated_by: current_admin.id)
  end
end
