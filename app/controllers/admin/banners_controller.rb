class Admin::BannersController < Admin::BaseController

  # GET /admin/banners
  def index
    authorize(AdminBanner)

    @admin_banners = AdminBanner.order("id DESC").paginate(page: params[:page])
  end

  # GET /admin/banners/1
  def show
    @admin_banner = authorize AdminBanner.find(params[:id])
  end

  # GET /admin/banners/new
  def new
    @admin_banner = authorize AdminBanner.new
  end

  # GET /admin/banners/1/edit
  def edit
    @admin_banner = authorize AdminBanner.find(params[:id])
  end

  # POST /admin/banners
  def create
    @admin_banner = authorize AdminBanner.new(admin_banner_params)

    if @admin_banner.save
      if @admin_banner.active?
        AdminBanner.banner_on
        flash[:notice] = t("admin.banners.create.banner_on")
      else
        flash[:notice] = t("admin.banners.create.success")
      end
      redirect_to @admin_banner
    else
      render action: 'new'
    end
  end

  # PUT /admin/banners/1
  def update
    @admin_banner = authorize AdminBanner.find(params[:id])

    if !@admin_banner.update(admin_banner_params)
      render action: 'edit'
    elsif params[:admin_banner_minor_edit]
      flash[:notice] = t("admin.banners.update.minor_edit")
      redirect_to @admin_banner
    else
      if @admin_banner.active?
        AdminBanner.banner_on
        flash[:notice] = t("admin.banners.update.banner_on")
      else
        flash[:notice] = t("admin.banners.update.success")
      end
      redirect_to @admin_banner
    end
  end

  # GET /admin/banners/1/confirm_delete
  def confirm_delete
    @admin_banner = authorize AdminBanner.find(params[:id])
    return unless @admin_banner.active?
    
    flash[:error] = t("admin.banners.cannot_delete_active")
    redirect_to @admin_banner
  end

  # DELETE /admin/banners/1
  def destroy
    @admin_banner = authorize AdminBanner.find(params[:id])
    if @admin_banner.active?
      flash[:error] = t("admin.banners.cannot_delete_active")
      redirect_to @admin_banner
    else
      @admin_banner.destroy
      flash[:notice] = t("admin.banners.destroy.success")
      redirect_to admin_banners_path
    end
  end

  private

  def admin_banner_params
    params.require(:admin_banner).permit(:content, :banner_type, :active)
  end

end
