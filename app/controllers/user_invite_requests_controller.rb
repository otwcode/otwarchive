class UserInviteRequestsController < ApplicationController
  before_filter :admin_only, :except => [:new, :create]

  # GET /user_invite_requests
  # GET /user_invite_requests.xml
  def index
    @user_invite_requests = UserInviteRequest.not_handled.page(params[:page])
  end

  # GET /user_invite_requests/new
  # GET /user_invite_requests/new.xml
  def new
    if AdminSetting.request_invite_enabled?
      if logged_in?
        @user = current_user
        @user_invite_request = @user.user_invite_requests.build
      else
        flash[:error] = ts("Please log in.")
        redirect_to login_path
     end
    else
      flash[:error] = ts("Sorry, new invitations are temporarily unavailable. If you are the mod of a challenge currently being run on the Archive, please <a href=\"#{new_feedback_report_url}\">contact Support</a>. If you are the maintainer of an at-risk archive, please contact <a href=\"http://opendoors.transformativeworks.org/contact/open doors\">Open Doors</a>".html_safe)
      redirect_to root_path
    end
  end
  # POST /user_invite_requests
  # POST /user_invite_requests.xml
  def create
    if AdminSetting.request_invite_enabled?
      if logged_in?
        @user = current_user
        @user_invite_request = @user.user_invite_requests.build(params[:user_invite_request])
      else
        flash[:error] = "Please log in."
        redirect_to login_path
      end
      if @user_invite_request.save
        flash[:notice] = 'Request was successfully created.'
        redirect_to(@user)
      else
        render :action => "new"
      end
    else
      flash[:error] = ts("Sorry, new invitations are temporarily unavailable. If you are the mod of a challenge currently being run on the Archive, please <a href=\"#{new_feedback_report_url}\">contact Support</a>. If you are the maintainer of an at-risk archive, please contact <a href=\"http://opendoors.transformativeworks.org/contact/open doors\">Open Doors</a>".html_safe)
      redirect_to root_path
    end
  end

  # PUT /user_invite_requests/1
  # PUT /user_invite_requests/1.xml
  def update
    if params[:decline_all]
      params[:requests].each_pair do |id, quantity|
        unless quantity.blank?
          request = UserInviteRequest.find(id)
          requested_total = request.quantity.to_i
          request.quantity = 0
          request.save!
          UserMailer.invite_request_declined(request.user_id, requested_total, request.reason).deliver
        end
      end
      flash[:notice] = 'All Requests were declined.'
      redirect_to user_invite_requests_url and return
    end
    params[:requests].each_pair do |id, quantity|
      unless quantity.blank?
        request = UserInviteRequest.find(id)
        request.quantity = quantity.to_i
        request.save!
      end
    end
    flash[:notice] = ts("Requests were successfully updated.")
    redirect_to user_invite_requests_url
  end
end
