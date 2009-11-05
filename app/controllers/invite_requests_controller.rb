class InviteRequestsController < ApplicationController
  # GET /invite_requests
  # GET /invite_requests.xml
  def index
    @invite_request = InviteRequest.new
  end

  # GET /invite_requests/1
  # GET /invite_requests/1.xml
  def show
    if params[:email]
      @invite_request = InviteRequest.find_by_email(params[:email])
      unless @invite_request
        flash[:error] = "Sorry, we couldn't find your address in our queue."
        redirect_to invite_requests_url      
      end    
    else
      @invite_request = InviteRequest.find(params[:id])
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
      flash[:notice] = "You've been added to our queue! Yay!"
      redirect_to @invite_request 
    else
      render :action => :index
    end
  end

end
