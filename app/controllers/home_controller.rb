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
    
    @fandom_count = TagCategory::FANDOM.tags.count(:all, :conditions => {:canonical => true})
    @latest_work = Work.visible.find(:first, :conditions => {:restricted => false}, :order => "works.revised_at DESC")
    @latest_fandom = @latest_work.tags.canonical.by_category(TagCategory::FANDOM).first if @latest_work
    render :action => "index", :layout => "home"
  end
  
end
