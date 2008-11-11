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
    @work_count = Work.visible.size
    unless @work_count.zero?
      @random_work = Work.visible.find(:first, :offset => rand(@work_count))
      unless @random_work.nil?
        @random_user = @random_work.pseuds.first.user
      end
    end
    @works_today = Work.visible.count(:all, :conditions => (['works.created_at > ?', 1.day.ago]))
    
    @fandom_count = Fandom.canonical.count
    @latest_work = Work.visible.find(:first, :conditions => {:restricted => false}, :order => "works.revised_at DESC")
    fandom = @latest_work.fandoms.first if @latest_work
    @latest_fandom = @latest_work.fandoms.first if fandom && fandom.canonical?
    render :action => "index", :layout => "home"
  end
  
end
