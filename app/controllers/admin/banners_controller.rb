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
        flash[:notice] = t(".banner_on")
      else
        flash[:notice] = t(".success")
      end
      redirect_to @admin_banner
    else
      render action: 'new'
    end

    AdminActivity.log_action(current_admin, @admin_banner, action: "create_admin_banner", summary: "Content: #{@admin_banner.content}, Type: #{@admin_banner.banner_type.presence || 'Default'}, Active: #{@admin_banner.active?}")
  end

  # PUT /admin/banners/1
  def update
    @admin_banner = authorize AdminBanner.find(params[:id])

    if !@admin_banner.update(admin_banner_params)
      render action: 'edit'
    elsif params[:admin_banner_minor_edit]
      flash[:notice] = t(".minor_edit")
      redirect_to @admin_banner
    else
      if @admin_banner.active?
        AdminBanner.banner_on
        flash[:notice] = t(".banner_on")
      else
        flash[:notice] = t(".success")
      end
      redirect_to @admin_banner
    end

    AdminActivity.log_action(current_admin, @admin_banner, action: "update_admin_banner", summary: "Content: #{@admin_banner.content}, Type: #{@admin_banner.banner_type.presence || 'Default'}, Active: #{@admin_banner.active?}")
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
      flash[:notice] = t(".success")
      redirect_to admin_banners_path
    end

    AdminActivity.log_action(current_admin, @admin_banner, action: "destroy_admin_banner", summary: "Content: #{@admin_banner.content}, Type: #{@admin_banner.banner_type.presence || 'Default'}")
  end

  private

  def admin_banner_params
    params.require(:admin_banner).permit(:content, :banner_type, :active)
  end

end
