class HomeController < ApplicationController

  before_filter :users_only, :only => [:site_pages]
  before_filter :check_permission_to_wrangle, :only => [:site_pages]
  skip_before_filter :store_location, :only => [:first_login_help]
  
  # terms of service
  def tos
    render :action => "tos", :layout => "application"
  end
  
  # terms of service faq
  def tos_faq 
    render :action => "tos_faq", :layout => "application"
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
    @user_count = User.count
    @work_count = Work.posted.count
    @fandom_count = Fandom.canonical.count
    @admin_posts = AdminPost.non_translated.find(:all, :order => "created_at DESC", :limit => 3)
    @admin_post_show_more = AdminPost.count > 3
    render :action => "index", :layout => "home"
  end


  # Generate links to all the pages on the site
  def site_pages    
    Rails.application.reload_routes!
    page_routes = Rails.application.routes.routes.select do |route|
      route.verb == "GET" && !route.name.blank? && !route.name.match(/^edit/) && !route.name.match("translat") && !route.name.match("external_author")
    end

    @paths = []
    @errors = []
    @errors << "Skipping translation and external author pages because these areas are in-progress."

    page_routes.each do |r|
      path = r.path.split('(').first
      while (path.match(/:([^\/]+)_id\//)) do
        id = get_id(path, current_user, $1.singularize)
        if id
          path.gsub!(":#{$1}_id", "#{id}") if id
          @last_id = id
        else
          @errors << "Couldn't find object for #{path}, #{$1}"
          break
        end
      end

      if (path.match(/\/([^\/]+)\/:id/))
        id = get_id(path, current_user, $1.singularize)
        if id
          path.gsub!(":id", "#{id}")
          @last_id = id
        else
          @errors << "Couldn't find object for #{path}, id"
        end
      end

      @paths << [path, r.name]
    end
    
    render :action => "site_pages", :layout => "application"
  end


protected

  # We try and get ids to use in paths here with a bit of custom guesswork
  # The fallback is just using the first object of a given class
  def get_id(path, user, classname)
    begin    
      if classname == "person"
        return People.all.first.to_param
      end
      
      object = case classname
      when "user"
        user || User.first
      when "pseud"
        user.try(:default_pseud) || Pseud.first
      when "medium"
        Media.first
      when "collection"
        user.owned_collections.first
      when "restricted_work"
        Work.where(:restricted => true).in_collection(Collection.find(@last_id)).first
      when "tag_wrangler"
        if permit?("tag_wrangler")
          user
        else
          Role.find_by_name("tag_wrangler").users.first
        end
      when "nomination"
        TagSetNomination.for_tag_set(OwnedTagSet.find(@last_id)).owned_by(user).first
      when "setting"
        AdminSetting.first
      when "assignment", "claim", "signup"
        klass = "challenge_#{classname}".classify.constantize
        query = classname == "assignment" ? klass.by_offering_user(user) :
                  (classname == "signup" ? klass.by_user(user) :  
                    (classname == "claim" ? klass.by_claiming_user(user) : nil))
        if path.match('collection')
          query = query.in_collection(Collection.find(@last_id))
        end
        query.first
      when "item", "participant"
        "collection_#{classname}".classify.constantize.where(:collection_id => @last_id).first
      when "tag_wrangling", "user_creation", "translator", "translation"
        # not real objects
        nil
      else
        klass = classname.classify.constantize
        if klass.column_names.include?("user_id")
          klass.where(:user_id => user.id).first
        elsif klass.column_names.include?("pseud_id")
          klass.where(:pseud_id => user.default_pseud.id).first
        else
          classname.classify.constantize.first
        end
      end

      # return the id
      object.try(:id)
    rescue
      @errors << "NOT SURE HOW TO FIND #{classname}"
      nil
    end      
  end


  
end
