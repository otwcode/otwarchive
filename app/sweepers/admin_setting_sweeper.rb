class AdminSettingSweeper < ActionController::Caching::Sweeper
  observe AdminSetting
  
  def after_save(admin_setting)
    expire_fragment("admin_settings")
  end

end
