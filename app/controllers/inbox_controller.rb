class InboxController < ApplicationController
  before_filter :is_owner
  
  def is_owner
    @user = User.find_by_login(params[:user_id])
    @user == current_user || access_denied
  end
  
  def show
    @inbox = @user.feedback_comments(:all, :order => 'feedback_comments.created_at DESC').uniq
  end
end
