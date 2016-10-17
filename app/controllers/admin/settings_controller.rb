class Admin::SettingsController < ApplicationController

  before_filter :authenticate_admin!

  def index
    @admin_setting = AdminSetting.first || AdminSetting.create(:last_updated_by => Admin.first)
  end

  # PUT /admin_settings/1
  # PUT /admin_settings/1.xml
  def update
    @admin_setting = AdminSetting.first || AdminSetting.create(:last_updated_by => Admin.first)

    if @admin_setting.update_attributes(params[:admin_setting])
      flash[:notice] = ts("Archive settings were successfully updated.")
      redirect_to admin_settings_path
    else
      render :action => "index"
    end
  end

end
