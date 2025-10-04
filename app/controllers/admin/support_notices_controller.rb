class Admin::SupportNoticesController < Admin::BaseController
  # GET /admin/notices/support
  def index
    authorize(SupportNotice)

    @pagy, @support_notices = pagy(SupportNotice.order(id: :desc))
  end

  # GET /admin/notices/support/1
  def show
    @support_notice = authorize SupportNotice.find(params[:id])
  end

  # GET /admin/notices/support/new
  def new
    @support_notice = authorize SupportNotice.new
  end

  # GET /admin/notices/support/1/edit
  def edit
    @support_notice = authorize SupportNotice.find(params[:id])
  end

  # POST /admin/notices/support
  def create
    @support_notice = authorize SupportNotice.new(support_notice_params)

    if @support_notice.save
      flash[:notice] = t(".created")
      redirect_to @support_notice
    else
      render action: "new"
    end
  end

  # PUT /admin/notices/support/1
  def update
    @support_notice = authorize SupportNotice.find(params[:id])

    if @support_notice.update(support_notice_params)
      flash[:notice] = t(".updated")
      redirect_to @support_notice
    else
      render action: "edit"
    end
  end

  # GET /admin/notices/support/1/confirm_delete
  def confirm_delete
    @support_notice = authorize SupportNotice.find(params[:id])
  end

  # DELETE /admin/notices/support/1
  def destroy
    @support_notice = authorize SupportNotice.find(params[:id])
    @support_notice.destroy

    flash[:notice] = t(".deleted")
    redirect_to admin_support_notices_path
  end

  def support_notice_url(id)
    admin_support_notice_url(id)
  end

  private

  def support_notice_params
    params.require(:support_notice).permit(:content, :support_notice_type, :active)
  end
end
