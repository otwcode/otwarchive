class Admin::AdminBannedValuesController < ApplicationController
  
  before_filter :admin_only

  def index
  end 

  def new
    @banned_value = BannedValue.new
  end
  
  def create

    @banned_value = current_admin.banned_values.new(params[:banned_value])
    if @banned_value.name.blank?
      flash[:error] = t('no_email', :default => "Value Must Be Entered")
      render :action => 'index'      
    elsif @banned_value.save
      flash[:notice] = t('sent', :default => "An invitation was sent to %{email_address}", :email_address => @invitation.invitee_email)
      redirect_to admin_invitations_url
    else
      render :action => 'index'
    end
  end

  
  def find
    unless params[:user_name].blank?
      @user = User.find_by_login(params[:user_name])
      @hide_dashboard = true
      @invitations = @user.invitations if @user
    end
    if !params[:token].blank?
      @invitation = Invitation.find_by_token(params[:token])
    elsif !params[:invitee_email].blank?
      @invitations = Invitation.find(:all, :conditions => ['invitee_email LIKE ?', '%' + params[:invitee_email] + '%'])
      @invitation = @invitations.first if @invitations.length == 1
    end
    unless @user || @invitation || @invitations
      flash.now[:error] = t('user_not_found', :default => "No results were found. Try another search.")
    end
  end

end  

