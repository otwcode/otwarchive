class InviteRequestsController < ApplicationController
  before_action :admin_only, only: [:manage, :destroy]

  # GET /invite_requests
  # Set browser page title to Invitation Requests
  def index
    @invite_request = InviteRequest.new
    @page_subtitle = t(".page_title")
  end

  # GET /invite_requests/1
  def show
    @invite_request = InviteRequest.find_by(email: params[:email])

    if @invite_request.present?
      @position_in_queue = @invite_request.position
    else
      @invitation = Invitation.unredeemed.from_queue.find_by(invitee_email: params[:email])
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def resend
    @invitation = Invitation.unredeemed.from_queue.find_by(invitee_email: params[:email])

    if @invitation.nil?
      flash[:error] = t("invite_requests.resend.not_found")
    elsif !@invitation.can_resend?
      flash[:error] = t("invite_requests.resend.not_yet",
                        count: ArchiveConfig.HOURS_BEFORE_RESEND_INVITATION)
    else
      @invitation.send_and_set_date(resend: true)

      if @invitation.errors.any?
        flash[:error] = @invitation.errors.full_messages.first
      else
        flash[:notice] = t("invite_requests.resend.success", email: @invitation.invitee_email)
      end
    end

    redirect_to status_invite_requests_path
  end

  # POST /invite_requests
  def create
    unless AdminSetting.current.invite_from_queue_enabled?
      flash[:error] = t("invite_requests.create.queue_disabled.html",
                        closed_bold: helpers.tag.strong(t("invite_requests.create.queue_disabled.closed")),
                        news_link: helpers.link_to(t("invite_requests.create.queue_disabled.news"), admin_posts_path(tag: 143)))
      redirect_to invite_requests_path
      return
    end

    @invite_request = InviteRequest.new(invite_request_params)
    @invite_request.ip_address = request.remote_ip
    if @invite_request.save
      flash[:notice] = t("invite_requests.create.success",
                         date: l(@invite_request.proposed_fill_time.to_date, format: :long),
                         return_address: ArchiveConfig.RETURN_ADDRESS)
      redirect_to invite_requests_path
    else
      render action: :index
    end
  end

  def manage
    authorize(InviteRequest)

    @invite_requests = InviteRequest.all

    if params[:query].present?
      query = "%#{params[:query]}%"
      @invite_requests = InviteRequest.where(
        "simplified_email LIKE ? OR ip_address LIKE ?",
        query, query
      )

      # Keep track of the fact that this has been filtered, so the position
      # will not cleanly correspond to the page that we're on and the index of
      # the request on the page:
      @filtered = true
    end

    @invite_requests = @invite_requests.order(:id).page(params[:page])
  end

  def destroy
    @invite_request = InviteRequest.find(params[:id])
    authorize @invite_request

    if @invite_request.destroy
      success_message = ts("Request for %{email} was removed from the queue.", email: @invite_request.email)
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
    @page_subtitle = t(".browser_title")
  end

  private

  def invite_request_params
    params.require(:invite_request).permit(
      :email, :query
    )
  end
end
