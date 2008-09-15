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
    @random_user = User.find_by_sql( "SELECT * FROM users WHERE id NOT IN 
                                      ( SELECT users.id FROM users INNER JOIN pseuds ON users.id = pseuds.user_id 
                                        INNER JOIN creatorships ON 
                                        (pseuds.id = creatorships.pseud_id AND creatorships.creation_type = 'Work') 
                                        INNER JOIN works ON 
                                        (creatorships.creation_id = works.id AND works.restricted = true) )
                                      ORDER BY RAND()
                                      LIMIT 1" ).first
    @work_count = Work.count(:all)
    @works_today = Work.count(:all, :conditions => (['created_at > ?', 1.day.ago]))
    fandom_category = TagCategory.find_or_create_by_name("Fandom")
    @fandom_count = fandom_category.tags.count(:all, :conditions => {:canonical => true})
    @latest_work = Work.find(:first, :conditions => {:restricted => false}, :order => "updated_at DESC")
    @latest_fandom = fandom_category.tags.find(:first, :conditions => {:name => @latest_work.Fandom})
    render :action => "index", :layout => "home"
  end
  
end
