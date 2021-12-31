class Admin::ReservedUsernamesController < Admin::BaseController

  def index
    @admin_reserved_username = AdminReservedUsername.new
    if params[:query]
      @admin_reserved_usernames = AdminReservedUsername.where(["username LIKE ?", '%' + params[:query] + '%'])
      @admin_reserved_usernames = @admin_reserved_usernames.paginate(page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE)
    end
  end

  def new
    @admin_reserved_username = AdminReservedUsername.new
  end

  def create
    @admin_reserved_username = AdminReservedUsername.new(admin_reserved_username_params)

    if @admin_reserved_username.save
      flash[:notice] = ts("Username #{@admin_reserved_username.username} added to reserved list.")
      redirect_to admin_reserved_usernames_path
    else
      render action: "index"
    end
  end

  def destroy
    @admin_reserved_username = AdminReservedUsername.find(params[:id])
    @admin_reserved_username.destroy

    flash[:notice] = ts("User name #{@admin_reserved_username.username} removed from reserved list.")
    redirect_to admin_reserved_usernames_path
  end

  private

  def admin_reserved_username_params
    params.require(:admin_reserved_username).permit(
      :username
    )
  end
end
