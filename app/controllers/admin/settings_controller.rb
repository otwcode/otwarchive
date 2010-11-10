class Admin::SettingsController < ApplicationController

  before_filter :admin_only

  def index
    @admin_setting = AdminSetting.first || AdminSetting.create
  end

  # PUT /admin_settings/1
  # PUT /admin_settings/1.xml
  def update
    @admin_setting = AdminSetting.first || AdminSetting.create
    if @admin_setting.update_attributes(params[:admin_setting])
      flash[:notice] = 'Archive settings were successfully updated.'
      redirect_to admin_settings_path
    else
      render :action => "index"
    end
  end

end
