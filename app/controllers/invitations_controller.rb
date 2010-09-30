class InvitationsController < ApplicationController

  before_filter :check_permission
  before_filter :admin_only, :only => [:create, :destroy]

  def check_permission
    @user = User.find_by_login(params[:user_id])
    access_denied unless logged_in_as_admin? || @user == current_user
  end

  def index
    @unsent_invitations = @user.invitations.unsent.limit(5)
  end
  
  def manage
    if params[:status].blank? || !['unsent', 'unredeemed', 'redeemed'].include?(params[:status])
      @invitations = @user.invitations
    else
      @invitations = @user.invitations.send(params[:status])
    end  
  end
  
  def show
    @invitation = Invitation.find(params[:id])
  end
  
  def invite_friend
    @invitation = @user.invitations.find(params[:id])
    if !params[:invitee_email].blank?
      @invitation.invitee_email = params[:invitee_email]
      if @invitation.save
        flash[:notice] = 'Invitation was successfully sent.'
        redirect_to([@user, @invitation]) 
      else
        render :action => "show"
      end
    else
      flash[:error] = "Please enter an email address."
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
    @invitation.attributes = params[:invitation]
    if @invitation.invitee_email_changed? && @invitation.update_attributes(params[:invitation])
      flash[:notice] = 'Invitation was successfully sent.'
      if logged_in_as_admin?
        redirect_to find_admin_invitations_url(:token => @invitation.token)
      else
        redirect_to([@user, @invitation])        
      end
    else
      flash[:error] = "Please enter an email address." if @invitation.invitee_email.blank?
      render :action => "show"
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    @user = @invitation.creator
    if @invitation.destroy
      flash[:notice] = "Invitation successfully destroyed"
    else
      flash[:error] = "Invitation was not destroyed."
    end
    if @user.is_a?(User)
      redirect_to user_invitations_url(@user)
    else
      redirect_to admin_invitations_url
    end      
  end

end
