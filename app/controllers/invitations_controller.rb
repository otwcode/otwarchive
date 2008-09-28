class InvitationsController < ApplicationController
  def index
    redirect_to new_invitation_path
  end
  
  def new
    if !current_user.respond_to?(:invitation_limit)
      flash[:error] = "Sorry, you must be logged in to create invitations.".t
      redirect_to login_path      
    elsif  current_user.invitation_limit < 1
      flash[:error] = "Sorry, you don't have any invitations available right now.".t
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
        flash[:notice] = "Your invitation has been sent!".t
        redirect_to current_user
      else
        flash[:notice] = "Thanks! You'll be added to our queue.".t
        redirect_to root_url
      end
    else
      render :action => 'new'
    end
  end
end
