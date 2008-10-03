class InboxController < ApplicationController
  before_filter :is_owner
  
  def is_owner
    @user = User.find_by_login(params[:user_id])
    @user == current_user || access_denied
  end
  
  def show
    @unread = @user.unread_comments
    @read = @user.read_comments
  end

  def update
    @selected_comment_ids = params[:comments].keys if params[:comments]
    if @selected_comment_ids.blank?
      flash[:warning] = "Please select something first".t
    else
      if params[:commit] == "delete comments from story"
        @selected_comment_ids.each {|c| 
        @comment = Comment.find(c)
        if current_user.is_author_of?(@comment) || current_user.is_author_of?(@comment.ultimate_parent)
          @comment.destroy_or_mark_deleted
        else flash[:error] = "Sorry, you don't have permission to delete some of those comments".t
        end }
      elsif params[:commit] == "read"
        @selected_comment_ids.each {|c| Comment.find(c).update_attribute(:is_read, true) }
      elsif params[:commit] == "unread"
        @selected_comment_ids.each {|c| Comment.find(c).update_attribute(:is_read, false) }
      elsif params[:commit] == "spam"
        @selected_comment_ids.each {|c| 
        @comment = Comment.find(c)
        if current_user.is_author_of?(@comment) || current_user.is_author_of?(@comment.ultimate_parent)      
        @comment.mark_as_spam!
        else flash[:error] = "Sorry, you don't have permission to mark some of those comments as spam".t
        end }
      end
    end
    redirect_to user_inbox_path(@user)
  end
end
