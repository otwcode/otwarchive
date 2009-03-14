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
      flash[:notice] = t('notices.admin_invitation.sent', :default => "An invitation was sent to {{email_address}}", :email_address => @invitation.recipient_email)
      redirect_to new_admin_invitation_url
    else
      render :action => 'new'
    end
  end

end  

