class InvitationsController < ApplicationController
  def index
    redirect_to new_invitation_path
  end
  
  def new
    if !current_user.respond_to?(:invitation_limit)
      flash[:error] = t('errors.invitations.log_in', :default => "Sorry, you must be logged in to create invitations.")
     redirect_to login_path      
    elsif  current_user.invitation_limit < 1
      flash[:error] = t('errors.invitations.none_available', :default => "Sorry, you don't have any invitations available right now.")
     redirect_to current_user
    else
      @invitation = Invitation.new
    end
  end

  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.sender = current_user
    if @invitation.save
      if logged_in?
        UserMailer.deliver_invitation(@invitation, signup_url(@invitation.token))
        flash[:notice] = t('errors.invitations.successfully_sent', :default => "Your invitation has been sent!")
       redirect_to current_user
      else
        flash[:notice] = t('errors.invitations.queued', :default => "Thanks! You'll be added to our queue.")
       redirect_to root_url
      end
    else
      render :action => 'new'
    end
  end
end
