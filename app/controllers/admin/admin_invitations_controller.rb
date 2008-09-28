class Admin::AdminInvitationsController < ApplicationController
  
  before_filter :admin_only

  def index
    redirect_to new_admin_invitation_url
  end 

  def new
    @invitation = Invitation.new
  end
  
  def create
    @invitation = Invitation.new(params[:invitation])
    if @invitation.save
      UserMailer.deliver_invitation(@invitation, signup_url(@invitation.token))
      flash[:notice] = "An invitation was sent to ".t + @invitation.recipient_email
      redirect_to new_admin_invitation_url
    else
      render :action => 'new'
    end
  end

end  

