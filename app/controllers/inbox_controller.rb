class InboxController < ApplicationController
  before_filter :is_owner
  
  def is_owner
    @user = User.find_by_login(params[:user_id])
    @user == current_user || access_denied
    @hide_dashboard = true
  end
  
  def show 
    @unread = @user.inbox_comments.count(:conditions => {:read => false})   
    order = 'created_at ' + (params[:sort_by_date] || 'DESC')     
    read = (params[:filter_read].blank? || params[:filter_read] == 'all') ? [true, false] : params[:filter_read] == 'true'
    replied_to = (params[:filter_replied_to].blank? || params[:filter_replied_to] == 'all') ? [true, false] : params[:filter_replied_to] == 'true'
    @inbox_comments = @user.inbox_comments.all(:order => order, :conditions => {:read => read, :replied_to => replied_to}, :include => [:feedback_comment => :pseud])
    @select_read, @select_replied_to, @select_date = params[:filter_read], params[:filter_replied_to], params[:sort_by_date]
  end
  
  def reply
    @commentable = Comment.find(params[:comment_id]) 
    @comment = Comment.new
  end

  def update
    @selected_inbox_comment_ids = params[:inbox_comments].keys if params[:inbox_comments]
    if @selected_inbox_comment_ids.blank?
      flash[:warning] = t('please_select', :default => "Please select something first")
    else
      if params[:commit] == "read"
        @selected_inbox_comment_ids.each {|inbox_comment| InboxComment.find(inbox_comment).update_attribute(:read, true) }
      elsif params[:commit] == "unread"
        @selected_inbox_comment_ids.each {|inbox_comment| InboxComment.find(inbox_comment).update_attribute(:read, false) }
      end
    end
    redirect_to user_inbox_path(@user)
  end
end
