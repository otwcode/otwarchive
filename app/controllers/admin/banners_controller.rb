class Admin::BannersController < ApplicationController

  before_filter :admin_only

  # GET /admin/banners
  # GET /admin/banners.xml
  def index   
    @admin_banners = AdminBanner.order("id DESC").paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/banners/1
  # GET /admin/banners/1.xml
  def show
    @admin_banner = AdminBanner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/banners/new
  # GET /admin/banners/new.xml
  def new
    @admin_banner = AdminBanner.new
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  # GET /admin/banners/1/edit
  def edit
    @admin_banner = AdminBanner.find(params[:id])
  end
  
  # POST /admin/banners
  # POST /admin/banners.xml
  def create
    @admin_banner = AdminBanner.new(params[:admin_banner])

    respond_to do |format|
      if @admin_banner.save
        flash[:notice] = 'Banner was successfully created.'
        format.html { redirect_to(@admin_banner) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/banners/1
  # PUT /admin/banners/1.xml
  def update
    @admin_banner = AdminBanner.find(params[:id])

    respond_to do |format|
      if @admin_banner.update_attributes(params[:admin_banner])
        flash[:notice] = 'Banner was successfully updated.'
        format.html { redirect_to(@admin_banner) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # GET /admin/banners/1/confirm_delete
  def confirm_delete
  end 
  
  # DELETE /admin/banners/1
  # DELETE /admin/banners/1.xml
  def destroy
    @admin_banner = AdminBanner.find(params[:id])
    @admin_banner.destroy

    respond_to do |format|
      format.html { redirect_to(admin_banners_url) }
    end
  end

end
