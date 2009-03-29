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
  
  def reply
    @commentable = Comment.find(params[:comment_id]) 
    @comment = Comment.new
  end

  def update
    @selected_comment_ids = params[:comments].keys if params[:comments]
    if @selected_comment_ids.blank?
      flash[:warning] = t('please_select', :default => "Please select something first")
   else
      if params[:commit] == "delete comments from story"
        @selected_comment_ids.each {|c| 
        @comment = Comment.find(c)
        if current_user.is_author_of?(@comment) || current_user.is_author_of?(@comment.ultimate_parent)
          @comment.destroy_or_mark_deleted
        else flash[:error] = t('permission_to_delete', :default => "Sorry, you don't have permission to delete some of those comments")
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
        else flash[:error] = t('permission_spam', :default => "Sorry, you don't have permission to mark some of those comments as spam")
       end }
      end
    end
    redirect_to user_inbox_path(@user)
  end
end
