class Admin::SupportNoticesController < Admin::BaseController
  before_action :load_support_notice, only: [:confirm_delete, :destroy, :edit, :show, :update]
  before_action :check_inactive, only: [:confirm_delete, :destroy]
  
  # GET /admin/notices/support
  def index
    authorize(SupportNotice)

    @pagy, @support_notices = pagy(SupportNotice.order(active: :desc, updated_at: :desc))
  end

  # GET /admin/notices/support/1
  def show
  end

  # GET /admin/notices/support/new
  def new
    @support_notice = authorize SupportNotice.new
  end

  # GET /admin/notices/support/1/edit
  def edit
  end

  # POST /admin/notices/support
  def create
    @support_notice = authorize SupportNotice.new(support_notice_params)
    
    if @support_notice.save
      flash[:notice] = t(".created")
      redirect_to admin_support_notice_path(@support_notice)
    else
      render action: "new"
    end
  end

  # PUT /admin/notices/support/1
  def update
    if @support_notice.update(support_notice_params)
      flash[:notice] = t(".updated")
      redirect_to admin_support_notice_path(@support_notice)
    else
      render action: "edit"
    end
  end

  # GET /admin/notices/support/1/confirm_delete
  def confirm_delete
  end

  # DELETE /admin/notices/support/1
  def destroy
    @support_notice.destroy

    flash[:notice] = t(".successfully_deleted")
    redirect_to admin_support_notices_path
  end

  private

  def load_support_notice
    @support_notice = authorize SupportNotice.find(params[:id])
  end

  def check_inactive
    return unless @support_notice.active?

    flash[:error] = t("admin.support_notices.cannot_delete_active")
    redirect_to admin_support_notice_path(@support_notice)
  end

  def support_notice_params
    params.require(:support_notice).permit(:notice, :support_notice_type, :active)
  end
end
