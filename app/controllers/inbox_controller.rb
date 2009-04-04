class InboxController < ApplicationController
  before_filter :load_user
  before_filter :check_ownership
  
  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
  end
  
  def show
    @hide_dashboard = true 
    @inbox_total = @user.inbox_comments.count
    @unread = @user.inbox_comments.count_unread
    filters = params[:filters] || {}   
    @inbox_comments = @user.inbox_comments.find_by_filters(filters)
    @select_read, @select_replied_to, @select_date = filters[:read], filters[:replied_to], filters[:date]
  end
  
  def reply
    @commentable = Comment.find(params[:comment_id]) 
    @comment = Comment.new
  end

  def update
    begin
      @inbox_comments = InboxComment.find(params[:inbox_comments].keys)
      case params[:commit]
        when 'read' then @inbox_comments.each { |i| i.update_attribute(:read, true) }
        when 'unread' then @inbox_comments.each { |i| i.update_attribute(:read, false) }
        when 'delete from inbox' then @inbox_comments.each { |i| i.destroy }
      end    
    rescue
      flash[:warning] = t('please_select', :default => "Please select something first")
    end
    redirect_to user_inbox_path(@user)
  end
end