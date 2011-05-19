class Admin::SettingsController < ApplicationController

  before_filter :admin_only

  def index
    @admin_setting = AdminSetting.first || AdminSetting.create(:last_updated_by => Admin.first)
  end

  # PUT /admin_settings/1
  # PUT /admin_settings/1.xml
  def update
    @admin_setting = AdminSetting.first || AdminSetting.create(:last_updated_by => Admin.first)
    
    if params[:banner_text] != @admin_setting.banner_text
      User.find(:all).each do |user|
        user.try(:preference).banner_seen = false
      end
    end
    
    if @admin_setting.update_attributes(params[:admin_setting])
      Rails.cache.delete("admin_settings")
      flash[:notice] = 'Archive settings were successfully updated.'
      redirect_to admin_settings_path
    else
      render :action => "index"
    end
  end

end
