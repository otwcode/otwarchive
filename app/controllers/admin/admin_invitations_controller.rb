class Admin::AdminInvitationsController < ApplicationController
  
  before_filter :admin_only

  def index
  end 

  def new
    @invitation = Invitation.new
  end
  
  def create
    @invitation = current_admin.invitations.new(params[:invitation])
    if @invitation.invitee_email.blank?
      flash[:error] = t('no_email', :default => "Please enter an email address.")
      render :action => 'index'      
    elsif @invitation.save
      flash[:notice] = t('sent', :default => "An invitation was sent to {{email_address}}", :email_address => @invitation.invitee_email)
      redirect_to admin_invitations_url
    else
      render :action => 'index'
    end
  end
  
  def invite_from_queue
    InviteRequest.find(:all, :order => :position, :limit => params[:invite_from_queue].to_i).each do |request|
      request.invite_and_remove(current_admin)
    end  
    flash[:notice] = t('invited_from_queue', :default => "{{count}} people from the invite queue were invited.", :count => params[:invite_from_queue].to_i)
    redirect_to admin_invitations_url
  end
  
  def grant_invites_to_users
    if params[:user_group] == "All"
      Invitation.grant_all(params[:number_of_invites].to_i)    
    else
      Invitation.grant_empty(params[:number_of_invites].to_i)
    end
    flash[:notice] = t('invites_created', :default => 'Invitations successfully created.')
    redirect_to admin_invitations_url
  end
  
  def find
    user = User.find_by_login(params[:user_name])
    if user
      redirect_to user_invitations_path(user)
    else
      flash[:error] = t('user_not_found', :default => "Sorry, we couldn't find a user with that name.")
      render :action => 'index'     
    end
  end

end  

