class HomeController < ApplicationController
  
  # terms of service
  def tos
    render :action => "tos", :layout => "application"
  end
  
  # terms of service faq
  def tos_faq 
    render :action => "tos_faq", :layout => "application"
  end
  
  # site map
  def site_map 
    render :action => "site_map", :layout => "application"
  end

  def first_login_help
    render :action => "first_login_help", :layout => false
  end

  # home page itself
  def index
    @user_count = User.count
    @work_count = Work.visible.size
    @fandom_count = Fandom.canonical.count
    @admin_post = AdminPost.find(:first, :order => "updated_at DESC")
    render :action => "index", :layout => "home"
  end
  
end
