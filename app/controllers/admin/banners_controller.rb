class Admin::BannersController < ApplicationController

  before_filter :admin_only

  def index
    @admin_banner = AdminBanner.first
  end

  # PUT /admin_banners/1
  # PUT /admin_banners/1.xml
  def update
    @admin_banner = AdminBanner.first
    
    if @admin_banner.update_attributes(params[:banner_text])
      AdminBanner.banner_on
      flash[:notice] = ts("Setting banner back on for all users. This may take some time.")
      redirect_to admin_banners_path
    else
      render :action => "index"
    end
  end

end
