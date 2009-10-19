class InviteRequestsController < ApplicationController
  # GET /invite_requests
  # GET /invite_requests.xml
  def index
    @invite_request = InviteRequest.new
  end

  # GET /invite_requests/1
  # GET /invite_requests/1.xml
  def show
    @invite_request = InviteRequest.find(params[:id])
  end

  def status
    @invite_request = InviteRequest.find_by_email(params[:email])
    if @invite_request
      redirect_to @invite_request
    else
      flash[:error] = "Sorry, we couldn't find your address in our queue."
      redirect_to invite_requests_url
    end
  end

  # POST /invite_requests
  # POST /invite_requests.xml
  def create
    @invite_request = InviteRequest.new(params[:invite_request])
    if @invite_request.save
      flash[:notice] = "You've been added to our queue! Yay!"
      redirect_to invite_requests_url 
    else
      render :action => :index
    end
  end

end
