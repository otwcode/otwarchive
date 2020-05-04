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
    if @admin_setting.update(admin_setting_params)
      flash[:notice] = ts("Archive settings were successfully updated.")
      redirect_to admin_settings_path
    else
      render action: "index"
    end
  end

  private
  def admin_setting_params
    params.require(:admin_setting).permit(
      policy(@admin_setting).permitted_attributes
    ).merge(last_updated_by: current_admin.id)
  end
end
