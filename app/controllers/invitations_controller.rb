# coding: utf-8
class InvitationsController < ApplicationController

  before_action :check_permission
  before_action :admin_only, only: [:create, :destroy]
  before_action :check_user_status, only: [:index, :manage, :invite_friend, :update]

  def check_permission
    @user = User.find_by(login: params[:user_id])
    access_denied unless logged_in_as_admin? || @user.present? && @user == current_user
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
    @invitation = @user.invitations.find(invitation_params[:id])

    if !invitation_params[:invitee_email].blank?
      @invitation.invitee_email = invitation_params[:invitee_email]
      if @invitation.save
        flash[:notice] = 'Invitation was successfully sent.'
        redirect_to([@user, @invitation])
      else
        render action: "show"
      end
    else
      flash[:error] = "Please enter an email address."
      render action: "show"
    end
  end

  def create
    if invitation_params[:number_of_invites].to_i > 0
      invitation_params[:number_of_invites].to_i.times do
        @user.invitations.create
      end
    end
    flash[:notice] = "Invitations were successfully created."
    redirect_to user_invitations_path(@user)
  end

  def update
    @invitation = Invitation.find(params[:id])
    @invitation.attributes = invitation_params

    if @invitation.invitee_email_changed? && @invitation.update_attributes(invitation_params)
      flash[:notice] = 'Invitation was successfully sent.'
      if logged_in_as_admin?
        redirect_to find_admin_invitations_path("invitation[token]" => @invitation.token)
      else
        redirect_to([@user, @invitation])
      end
    else
      flash[:error] = "Please enter an email address." if @invitation.invitee_email.blank?
      render action: "show"
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
      redirect_to user_invitations_path(@user)
    else
      redirect_to admin_invitations_path
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:id, :invitee_email, :number_of_invites)
  end
end
