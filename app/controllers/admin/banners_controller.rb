class Admin::BannersController < ApplicationController

  before_filter :admin_only

  # GET /admin/banners
  def index   
    @admin_banners = AdminBanner.order("id DESC").paginate(:page => params[:page])
  end

  # GET /admin/banners/1
  def show
    @admin_banner = AdminBanner.find(params[:id])
  end

  # GET /admin/banners/new
  def new
    @admin_banner = AdminBanner.new
  end
  
  # GET /admin/banners/1/edit
  def edit
    @admin_banner = AdminBanner.find(params[:id])
  end
  
  # POST /admin/banners
  def create
    @admin_banner = AdminBanner.new(params[:admin_banner])

    if @admin_banner.save
      if @admin_banner.active?
        AdminBanner.banner_on
        flash[:notice] = ts('Setting banner back on for all users. This may take some time.')
      else
        flash[:notice] = ts('Banner successfully created.')
      end
      redirect_to @admin_banner
    else
      render action: 'new'
    end
  end

  # PUT /admin/banners/1
  def update
    @admin_banner = AdminBanner.find(params[:id])

    if @admin_banner.update_attributes(params[:admin_banner])
      if @admin_banner.active?
        AdminBanner.banner_on
        flash[:notice] = ts('Setting banner back on for all users. This may take some time.')
      else
        flash[:notice] = ts('Banner successfully updated.')
      end
      redirect_to @admin_banner
    else
      render action: 'edit'
    end
  end
  
  # GET /admin/banners/1/confirm_delete
  def confirm_delete
    @admin_banner = AdminBanner.find(params[:id])
  end 
  
  # DELETE /admin/banners/1
  def destroy
    @admin_banner = AdminBanner.find(params[:id])
    @admin_banner.destroy

    flash[:notice] = ts('Banner successfully deleted.')
    redirect_to admin_banners_url
  end

end
