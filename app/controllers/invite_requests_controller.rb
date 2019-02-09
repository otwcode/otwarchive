class InviteRequestsController < ApplicationController
  before_action :admin_only, only: [:manage, :reorder, :destroy]

  # GET /invite_requests
  def index
    @invite_request = InviteRequest.new
  end

  # GET /invite_requests/1
  def show
    fetch_admin_settings # we normally skip this for js requests
    @invite_request = InviteRequest.find_by(email: params[:email])
    unless (request.xml_http_request?) || @invite_request
      flash[:error] = "You can search for the email address you signed up with below. If you can't find it, your invitation may have already been emailed to that address; please check your email spam folder as your spam filters may have placed it there."
      redirect_to status_invite_requests_path and return
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /invite_requests
  def create
    unless @admin_settings.invite_from_queue_enabled?
      flash[:error] = ts("<strong>New invitation requests are currently closed.</strong> For more information, please check the %{news}.",
                         news: view_context.link_to("\"Invitations\" tag on AO3 News", admin_posts_path(tag: 143))).html_safe
      redirect_to invite_requests_path
      return
    end

    @invite_request = InviteRequest.new(invite_request_params)
    if @invite_request.save
      flash[:notice] = "You've been added to our queue! Yay! We estimate that you'll receive an invitation around #{@invite_request.proposed_fill_date}. We strongly recommend that you add do-not-reply@archiveofourown.org to your address book to prevent the invitation email from getting blocked as spam by your email provider."
      redirect_to invite_requests_path
    else
      render action: :index
    end
  end

  def manage
    @invite_requests = InviteRequest.order(:position).page(params[:page])
    if params[:query].present?
      @invite_requests = InviteRequest.where("simplified_email LIKE ?",
                                             "%#{params[:query]}%")
                                      .order(:position)
                                      .page(params[:page])
    end
  end

  def reorder
    if InviteRequest.reset_order
      flash[:notice] = "The queue has been successfully updated."
    else
      flash[:error] = "Something went wrong. Please try that again."
    end
    redirect_to manage_invite_requests_path
  end

  def destroy
    @invite_request = InviteRequest.find_by(id: params[:id])
    if @invite_request.nil? || @invite_request.destroy
      success_message = if @invite_request.nil?
                          ts("Request was removed from the queue.")
                        else
                          ts("Request for %{email} was removed from the queue.", email: @invite_request.email)
                        end
      respond_to do |format|
        format.html { redirect_to manage_invite_requests_path(page: params[:page], query: params[:query]), notice: success_message }
        format.json { render json: { item_success_message: success_message }, status: :ok }
      end
    else
      error_message = ts("Request could not be removed. Please try again.")
      respond_to do |format|
        format.html do
          flash.keep
          redirect_to manage_invite_requests_path(page: params[:page], query: params[:query]), flash: { error: error_message }
        end
        format.json { render json: { errors: error_message }, status: :unprocessable_entity }
      end
    end
  end

  def status
    @page_subtitle = ts("Invitation Request Status")
  end

  private

  def invite_request_params
    params.require(:invite_request).permit(
      :email, :query
    )
  end
end
