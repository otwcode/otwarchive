class WorksController < ApplicationController
  # only registered users and NOT admin should be able to create new works
  before_filter :users_only, :only => [ :new, :create ]
  # only authors of a work should be able to edit it
  before_filter :is_author, :only => [ :edit, :update, :destroy ]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :manage_chapters, :preview, :post, :show ]
  before_filter :update_or_create_reading, :only => [ :show ]
  before_filter :check_permission_to_view, :only => [ :show ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update, :preview, :post]
  
  # We may want to move this to a module
  def self.auto_complete_for_taggable(model)
    TagCategory.official.each do |c|
      define_method("auto_complete_for_" + model.to_s.downcase + "_" + c.name.downcase){
        category = TagCategory.find(params[:tag_category_id])
        @tags = category.tags.find(:all, :conditions => [ 'LOWER(name) LIKE ?', '%' + params[:search].strip + '%' ], :limit => 10)
        render :inline => "<%= auto_complete_result(@tags, 'name')%>"        
      }
    end
  end
  
  auto_complete_for_taggable :work
  
  # For the auto-complete field in the works form
  def auto_complete_for_pseud_byline
    byline = request.raw_post.to_s.strip
    if byline.include? "["
      split = byline.split('[', 2)
      pseud_name = split.first.strip
      user_login = split.last.strip.chop
      conditions = [ 'LOWER(users.login) LIKE ? AND LOWER(name) LIKE ?','%' + user_login + '%',  '%' + pseud_name + '%' ]
    else
      conditions = [ 'LOWER(name) LIKE ?', '%' + byline + '%' ]
    end
    @pseuds = Pseud.find(:all, :include => :user, :conditions => conditions, :limit => 10)
    render :inline => "<%= auto_complete_result(@pseuds, 'byline')%>"
  end
  
  def access_denied
    store_location 
    redirect_to new_session_path(:restricted => true)
    false
  end

  # Sets values for @work, @chapter, @coauthor_results, @pseuds, and @selected_pseuds
  def set_instance_variables
    if params[:pseud] && params[:pseud][:byline] && params[:work][:author_attributes]
      params[:work][:author_attributes][:byline] = params[:pseud][:byline]
      params[:pseud][:byline] = ""
    end
    
    if params[:id] # edit, update, preview, post, manage_chapters
      @work = Work.find(params[:id])
      if params[:work]  # editing, don't lose our changes
        @work.attributes = params[:work]
      end
    elsif params[:work]
      @work = Work.new(params[:work])    
    else # new
      if current_user.unposted_work
        @work = current_user.unposted_work
      else
        @work = Work.new
        @work.chapters.build
      end
    end

    @chapters = @work.chapters.in_order
    @serial_works = @work.serial_works

    @chapter = @work.first_chapter
    logger.info "********* got here with work " + @work.to_yaml
    if params[:work] && params[:work][:chapter_attributes]
      logger.info "********* in params work setting chapter content "
      @chapter.content = params[:work][:chapter_attributes][:content]
    end
    
    unless current_user == :false
      @pseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
      to_select = @work.authors.blank? ? @work.pseuds.blank? ? [current_user.default_pseud] : @work.pseuds : @work.authors 
      @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
      @series = current_user.series 
    end
  end
  
  # Only authors of the work should be able to edit it
  def is_author
    @work = Work.find(params[:id])
    unless current_user.is_a?(User) && current_user.is_author_of?(@work)
      flash[:error] = 'Sorry, but you don\'t have permission to make edits.'.t
      redirect_to(@work)     
    end
  end
  
  # Only authorized users should be able to access restricted/hidden works
  def check_permission_to_view
    @work = Work.find(params[:id])
    can_view_hidden = is_admin? || (current_user.is_a?(User) && current_user.is_author_of?(@work))
	  access_denied if (!is_registered_user? && @work.restricted?)
	  if (!can_view_hidden && @work.hidden_by_admin?)
	    flash[:error] = 'This page is unavailable.'.t
      redirect_to works_path
    end
  end
   
  # GET /works
  def index
    case params[:sort_column]
      when "title" then
        sort_order = "works.title " + (params[:sort_direction] == "DESC" ? "DESC" : "ASC")
      when "word_count" then
        sort_order = "works.word_count " + (params[:sort_direction] == "DESC" ? "DESC" : "ASC")
      when "date" then
        sort_order = "works.created_at " + (params[:sort_direction] == "DESC" ? "DESC" : "ASC")
      else
        sort_order = "works.created_at DESC" # default sort order
    end
    
    if params[:user_id]
      @user = User.find_by_login(params[:user_id])
      @works = is_admin? ? @user.works.find(:all, :include => :tags, :order => sort_order).paginate(:page => params[:page]) : 
                           @user.works.visible(current_user, :include => :tags, :order => sort_order).paginate(:page => params[:page])
    elsif params[:fandom_id]
      @tag = Tag.find(params[:fandom_id])
      @works = is_admin? ? @tag.works.find(:all, :include => :tags, :order => sort_order).paginate(:page => params[:page]) : 
                           @tag.works.visible(current_user, :include => :tags, :order => sort_order).paginate(:page => params[:page])
    else
     @works = is_admin? ? Work.find(:all, :include => :tags, :order => sort_order).paginate(:page => params[:page]) : 
                          Work.visible(current_user, :include => :tags, :order => sort_order).paginate(:page => params[:page])
    end
    @tag_categories = TagCategory.official
    @filters = @tag_categories - [TagCategory.default]
    @tags_by_filter = {}
    @filters.each do |filter|
      @tags_by_filter[filter] = Tag.by_category(filter).valid.by_popularity & @works.collect(&:tags).flatten.uniq
    end   
  end
  
  # GET /works/1
  # GET /works/1.xml
  def show
    unless @work.series.blank?
      @series_previous = {}
      @series_next = {}
      for series in @work.series
        serial = series.serial_works.find(:first, :conditions => {:work_id => @work.id})
        sw_previous = series.serial_works.find(:first, :conditions => {:position => (serial.position - 1)})
        sw_next = series.serial_works.find(:first, :conditions => {:position => (serial.position + 1)})
        @series_previous[series.id] = sw_previous.work if sw_previous
        @series_next[series.id] = sw_next.work if sw_next
      end
    end
    if !is_admin? && !@work.visible(current_user)
      render :file => "#{RAILS_ROOT}/public/403.html",  :status => 403 and return
    elsif @work.adult? &&  !see_adult? 
      @back = request.env["HTTP_REFERER"]
      @back = root_path unless @back
      if @back == work_url(@work)
        session[:adult] = true
      else
        render :action => "adult" and return
      end
    end
    @chapters = @work.chapters
    @tag_categories = TagCategory.official
    @tag_categories_limited = TagCategory.official - [TagCategory.find_by_name("Warning")]
  end
  
  # GET /works/new
  def new
    
  end

  # POST /works
  def create

    if !@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank?
      @work.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
    elsif params[:edit_button]
      render :action => :new
    elsif params[:cancel_coauthor_button]
      render :action => :new
    elsif params[:cancel_button]
      flash[:notice] = "Story posting canceled."
      # destroy unposted works
      if current_user.unposted_work
        current_user.unposted_work.destroy
      end
      redirect_to current_user    
    else  
      if @work.save
        flash[:notice] = 'Work was successfully created.'.t
        redirect_to preview_work_path(@work)
      else
        render :action => :new 
      end
    end
  end
  
  # GET /works/1/edit
  def edit
    if params["remove"] == "me"
      pseuds_with_author_removed = @work.pseuds - current_user.pseuds
      if pseuds_with_author_removed.empty? 
        redirect_to :controller => 'orphans', :action => 'new', :work_id => @work.id    
      else
        @work.pseuds = pseuds_with_author_removed
        @work.save
        @work.chapters.each do |c| 
          c.pseuds = c.pseuds - current_user.pseuds
          if c.pseuds.empty?
            c.pseuds = @work.pseuds
          end
          c.save
        end
        flash[:notice] = "You have been removed as an author from the work".t
        redirect_to current_user
      end
    end
  end
  
  # PUT /works/1
  def update
    @work.attributes = params[:work]
    @tag_categories = TagCategory.official
    
    # Need to update @pseuds and @selected_pseuds values so we don't lose new co-authors if the form needs to be rendered again
    @pseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
    to_select = @work.authors.blank? ? @work.pseuds.blank? ? [current_user.default_pseud] : @work.pseuds : @work.authors 
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
   
    if !@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank? 
      @work.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
    elsif params[:preview_button]
      @preview_mode = true
  	  @chapters = [@chapter]
      render :action => "preview"
    elsif params[:cancel_button]
      flash[:notice] = "Story posting canceled."
      # destroy unposted works
      if current_user.unposted_work
        current_user.unposted_work.destroy
      end
      redirect_to current_user    
    elsif params[:edit_button]
      render :partial => 'work_form', :layout => 'application'
    else
      saved = true
      @chapter.save || saved = false
      @work.posted = true 
      @work.save || saved = false
      @work.update_minor_version
      if saved
        if params[:post_button]
          flash[:notice] = 'Work was successfully posted.'.t
        elsif params[:update_button]
          flash[:notice] = 'Work was successfully updated.'.t
        end
        redirect_to(@work)
      else
        @work.errors.add(:base, "Please double-check the length of your story: it cannot be blank and must be less than 16MB in size.".t) unless @chapter.valid?
        if !@work.has_required_tags?
          @preview_mode = true
      	  @chapters = [@chapter]
          render :action => "preview"
        else
          render :action => :new
        end
      end
    end 
  end
 
  # GET /works/1/preview
  def preview
    @preview_mode = true
    @tag_categories = TagCategory.official
  end
  
  # POST /works/1/post
  def post
    if params[:cancel_button]
      redirect_back_or_default('/') 
    elsif params[:edit_button]
      redirect_to edit_work_path(@work)
    else
      @work.posted = true
      if @work.save 
        flash[:notice] = 'Work has been posted!'.t
        redirect_to(@work)
      else
        render :action => "preview"
      end
    end
  end
  
  # DELETE /works/1
  def destroy
    @work = Work.find(params[:id])
    @work.destroy
    redirect_to(works_url)
  end
  
  protected

  # create a reading object when showing a work, but only if the user has reading 
  # history enabled and is not the author of the work
  def update_or_create_reading
    if logged_in? && current_user.preference.history_enabled
      unless current_user.is_author_of?(@work)
        reading = Reading.find_or_initialize_by_work_id_and_user_id(@work.id, current_user.id)
        reading.major_version_read, reading.minor_version_read = @work.major_version, @work.minor_version
        reading.save
      end
    end
    true
  end

end
