class InvitationsController < ApplicationController

  before_filter :check_permission

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
  end
  
  def show
    @invitation = Invitation.find(params[:id])
  end
  
  def update
    @invitation = Invitation.find(params[:id])
    if @invitation.update_attributes(params[:invitation])
      #UserMailer.deliver_invitation(@invitation, signup_url(@invitation.token))
      flash[:notice] = 'Invitation was successfully sent.'
      redirect_to(@invitation) 
    else
      render :action => "show"
    end
  end

end
