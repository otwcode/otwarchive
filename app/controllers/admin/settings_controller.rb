class Admin::SettingsController < ApplicationController

  before_filter :admin_only

  def index
    @admin_setting = AdminSetting.first || AdminSetting.create(:last_updated_by => Admin.first)
  end

  # PUT /admin_settings/1
  # PUT /admin_settings/1.xml
  def update
    @admin_setting = AdminSetting.first || AdminSetting.create(:last_updated_by => Admin.first)
    
    if params[:admin_setting][:banner_text] != @admin_setting.banner_text && @admin_setting.update_attributes(params[:admin_setting])
      AdminSetting.banner_on
      flash[:notice] = ts("Setting banner back on for all users. This may take some time")
      redirect_to admin_settings_path
    elsif @admin_setting.update_attributes(params[:admin_setting])
      flash[:notice] = ts("Archive settings were successfully updated.")
      redirect_to admin_settings_path
    else
      render :action => "index"
    end
  end

end
