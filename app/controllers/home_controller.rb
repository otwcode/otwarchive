class HomeController < ApplicationController
  
  # terms of service
  def tos 
  end
  
  # home page itself
  def index
    @user_count = User.count(:all)
    @work_count = Work.count(:all)
    @works_today = Work.count(:all, :conditions => (['created_at > ?', 1.day.ago]))
    render :action => "index", :layout => "home"
  end
  
end
