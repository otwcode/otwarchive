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
    read = case params[:filter_read]
      when 'true' then true
      when 'false' then false
      else [true, false]
    end
    replied_to = case params[:filter_replied_to]
      when 'true' then true
      when 'false' then false
      else [true, false]
    end
    @inbox_comments = @user.inbox_comments.all(:order => order, 
                                               :conditions => {:read => read, :replied_to => replied_to}, 
                                               :include => [:feedback_comment => :pseud])
    @select_read, @select_replied_to, @select_date = params[:filter_read], params[:filter_replied_to], params[:sort_by_date]
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
