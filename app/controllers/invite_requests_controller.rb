class InviteRequestsController < ApplicationController
  before_filter :admin_only, :only => [:manage, :reorder, :destroy]
  
  # GET /invite_requests
  # GET /invite_requests.xml
  def index
    @invite_request = InviteRequest.new
  end

  # GET /invite_requests/1
  # GET /invite_requests/1.xml
  def show
    @invite_request = InviteRequest.find_by_email(params[:email])
    unless (request.xml_http_request?) || @invite_request
      flash[:error] = "You can search for the email address you signed up with below. If you can't find it, your invitation may have already been emailed to that address; please check your email Spam folder as your spam filters may have placed it there."
      redirect_to invite_requests_url and return
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /invite_requests
  # POST /invite_requests.xml
  def create
    @invite_request = InviteRequest.new(params[:invite_request])
    if @invite_request.save
      flash[:notice] = "You've been added to our queue! Yay! We estimate that you'll receive an invitation around #{@invite_request.proposed_fill_date}. We strongly recommend that you add do-not-reply@archiveofourown.org to your address book to prevent the invitation email from getting blocked as spam by your email provider."
      redirect_to invite_requests_path
    else
      render :action => :index
    end
  end
  
  def manage
    @invite_requests = InviteRequest.order(:position).page(params[:page])
  end
  
  def reorder
    if InviteRequest.reset_order
      flash[:notice] = "The queue has been successfully updated."
    else
      flash[:error] = "Something went wrong. Please try that again."
    end
    redirect_to manage_invite_requests_url
  end
  
  def destroy
    @invite_request = InviteRequest.find(params[:id])
    if @invite_request.destroy
      flash[:notice] = "Request was removed from the queue."
    else
      flash[:error] = "Request could not be removed. Please try again."
    end
    redirect_to manage_invite_requests_url
  end
end
