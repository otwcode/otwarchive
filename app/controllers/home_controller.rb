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
    @user_count = User.count
    @work_count = Work.posted.count
    unless @work_count.zero?
      @random_user = Work.posted[rand(@work_count)].pseuds.first.user
    end
    @works_today = Work.posted.count(:all, :conditions => (['created_at > ?', 1.day.ago]))
    
    @fandom_count = TagCategory::FANDOM.tags.count(:all, :conditions => {:canonical => true})
    @latest_work = Work.posted.find(:first, :conditions => {:restricted => false}, :order => "updated_at DESC")
    @latest_fandom = @latest_work.tags.canonical.by_category(TagCategory::FANDOM).first if @latest_work
    render :action => "index", :layout => "home"
  end
  
end
