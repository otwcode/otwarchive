class InboxController < ApplicationController
  before_filter :load_user
  before_filter :check_ownership
  
  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
  end
  
  def show
    @inbox_total = @user.inbox_comments.count
    @unread = @user.inbox_comments.count_unread
    filters = params[:filters] || {}   
    @inbox_comments = @user.inbox_comments.find_by_filters(filters).page(params[:page])
    @select_read, @select_replied_to, @select_date = filters[:read], filters[:replied_to], filters[:date]
  end
  
  def reply
    @commentable = Comment.find(params[:comment_id]) 
    @comment = Comment.new
    respond_to do |format|
      format.html do
        redirect_to comment_path(@commentable, :add_comment_reply_id => @commentable.id, :anchor => 'comment_' + @commentable.id.to_s)
      end
      format.js
    end
  end
  
  def update
    begin
      @inbox_comments = InboxComment.find(params[:inbox_comments])
      if params[:read]
        @inbox_comments.each { |i| i.update_attribute(:read, true) }
      elsif params[:unread]
        @inbox_comments.each { |i| i.update_attribute(:read, false) }
      elsif params[:delete]
        @inbox_comments.each { |i| i.destroy }
      end    
    rescue
      flash[:caution] = ts("Please select something first")
    end
    redirect_to user_inbox_path(@user, :filters => params[:filters])
  end
end
