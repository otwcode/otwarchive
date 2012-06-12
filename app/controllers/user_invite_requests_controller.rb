class UserInviteRequestsController < ApplicationController
  before_filter :admin_only, :except => [:new, :create]

  # GET /user_invite_requests
  # GET /user_invite_requests.xml
  def index
    @user_invite_requests = UserInviteRequest.not_handled
  end

  # GET /user_invite_requests/new
  # GET /user_invite_requests/new.xml
  def new
    setflash; flash[:error] = "Sorry, new invitations are not currently available. If you're a challenge mod or are looking to preserve works from another site, please contact Support."
    redirect_to root_path
    # if logged_in? 
    #   @user = current_user
    #   @user_invite_request = @user.user_invite_requests.build
    # else
    #   setflash; flash[:error] = "Please log in."
    #   redirect_to login_path
    # end
  end

  # POST /user_invite_requests
  # POST /user_invite_requests.xml
  def create
    setflash; flash[:error] = "Sorry, new invitations are not currently available. If you're a challenge mod or are looking to preserve works from another site, please contact Support."
    redirect_to root_path
    # if logged_in? 
    #   @user = current_user
    #   @user_invite_request = @user.user_invite_requests.build(params[:user_invite_request])
    # else
    #   setflash; flash[:error] = "Please log in."
    #   redirect_to login_path
    # end
    # if @user_invite_request.save
    #   setflash; flash[:notice] = 'Request was successfully created.'
    #   redirect_to(@user)
    # else
    #   render :action => "new"
    # end
  end

  # PUT /user_invite_requests/1
  # PUT /user_invite_requests/1.xml
  def update
    params[:requests].each_pair do |id, quantity|
      unless quantity.blank?
        request = UserInviteRequest.find(id)
        request.quantity = quantity.to_i
        request.save!
      end
    end
    setflash; flash[:notice] = 'Requests were successfully updated.'
    redirect_to user_invite_requests_url
  end
end
