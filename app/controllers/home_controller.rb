class HomeController < ApplicationController
  
  # terms of service
  def tos 
  end
  
  # home page itself
  def index
    @users = User.find(:all)
    @works = Work.find(:all)
    @works_today = Work.find(:all, :conditions => (['created_at > ?', 1.day.ago]))
    render :action => "index", :layout => "home"
  end
  
end
