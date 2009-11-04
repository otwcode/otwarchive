class InvitationsController < ApplicationController

  before_filter :check_permission
  before_filter :admin_only, :only => [:create, :destroy]

  def check_permission
    @user = User.find_by_login(params[:user_id])
    access_denied unless logged_in_as_admin? || @user == current_user
  end

  def index
    if params[:status].blank?
      @invitations = @user.invitations
    else
      @invitations = eval("@user.invitations." + params[:status])
    end
    @unsent_invitations = @user.invitations.unsent.find(:all, :limit => 5)
  end
  
  def show
    @invitation = Invitation.find(params[:id])
  end
  
  def invite_friend
    @invitation = @user.invitations.find(params[:id])
    @invitation.invitee_email = params[:invitee_email]
    if @invitation.save
      flash[:notice] = 'Invitation was successfully sent.'
      redirect_to([@user, @invitation]) 
    else
      render :action => "show"
    end    
  end
  
  def create
    if params[:number_of_invites].to_i > 0
      params[:number_of_invites].to_i.times do
        @user.invitations.create
      end
    end
    flash[:notice] = "Invitations were successfully created."
    redirect_to user_invitations_url(@user)
  end
  
  def update
    @invitation = Invitation.find(params[:id])
    if @invitation.update_attributes(params[:invitation])
      flash[:notice] = 'Invitation was successfully sent.'
      if logged_in_as_admin?
        redirect_to find_admin_invitations_url(:token => @invitation.token)
      else
        redirect_to([@user, @invitation])        
      end
    else
      render :action => "show"
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    if @invitation.destroy
      flash[:notice] = "Invitation successfully destroyed"
    else
      flash[:error] = "Invitation was not destroyed."
    end
    redirect_to user_invitations_url(@user)
  end

end
