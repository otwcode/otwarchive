class HomeController < ApplicationController
  
  # terms of service
  def tos
    render :action => "tos", :layout => "application"
  end
  
  # terms of service faq
  def tos_faq 
    render :action => "tos_faq", :layout => "application"
  end

  # home page itself
  def index
    @user_count = User.count(:all)
    @work_count = Work.count(:all)
    @works_today = Work.count(:all, :conditions => (['created_at > ?', 1.day.ago]))
    render :action => "index", :layout => "home"
  end
  
end
