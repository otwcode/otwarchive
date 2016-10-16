class HomeController < ApplicationController

  skip_before_filter :store_location, :only => [:first_login_help]
  
  # unicorn_test
  def unicorn_test
  end

  # terms of service
  def tos
    render :action => "tos", :layout => "application"
  end
  
  # terms of service faq
  def tos_faq 
    render :action => "tos_faq", :layout => "application"
  end

  # dmca policy
  def dmca 
    render :action => "dmca", :layout => "application"
  end

  # lost cookie
  def lost_cookie
    render action: 'lost_cookie', layout: 'application'
  end
  
  # diversity statement
  def diversity 
    render :action => "diversity_statement", :layout => "application"
  end
  
  # site map
  def site_map 
    render :action => "site_map", :layout => "application"
  end
  
  # donate
  def donate
    render :action => "donate", :layout => "application"
  end
  
  # about
  def about
    render :action => "about", :layout => "application"
  end
  
  def first_login_help
    render :action => "first_login_help", :layout => false
  end

  # home page itself
  def index
    @homepage = Homepage.new(@current_user)
    unless @homepage.logged_in?
      @user_count, @work_count, @fandom_count = @homepage.rounded_counts
    end

    @hide_dashboard = true
    render action: 'index', layout: 'application'
  end
end
