class WorksController < ApplicationController 
  include HtmlFormatter  
    
  # only registered users and NOT admin should be able to create new works
  before_filter :users_only, :only => [ :new, :create ]
  # only authors of a work should be able to edit it
  before_filter :is_author, :only => [ :edit, :update, :destroy ]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :manage_chapters, :preview, :post, :show, :upload_work ]
  before_filter :update_or_create_reading, :only => [ :show ]
  before_filter :check_adult_status, :only => [:show]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update, :preview, :post]
  
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
  # and @tags[category]
  def set_instance_variables
    if params[:pseud] && params[:pseud][:byline] && params[:work][:author_attributes]
      params[:work][:author_attributes][:byline] = params[:pseud][:byline]
      params[:pseud][:byline] = ""
    end
    begin    
      if params[:id] # edit, update, preview, post, manage_chapters
        @work = Work.find(params[:id])
        if params[:work]  # editing, don't lose our changes
          @work.attributes = params[:work]
        end
      elsif params[:work]
         @work = Work.new(params[:work])    
        
      else # new
          @work = Work.new
          @work.chapters.build
      end

      @chapters = @work.chapters.in_order
      @serial_works = @work.serial_works
      @tags_by_category = {}
      categories = (TagCategory.exclusive + [TagCategory.find_by_name("Warning")]).flatten.compact.uniq
      categories.each {|category| @tags_by_category[category] = category.tags.valid.canonical} unless categories.blank?
  
      @chapter = @work.first_chapter
      if params[:work] && params[:work][:chapter_attributes]
        @chapter.content = params[:work][:chapter_attributes][:content]
      end
      
      # This is a horrifying kludge for which there is no excuse except that
      # it makes the chapter attribute change actually get loaded for NO REASON
      # I can understand! -- Naomi 9/9/08
      # This only works if it is to_yaml (to_s does NOT) which suggests something is happening
      # during the yaml dump. More investigation needed. D: 
      stupid_garbage_variable = @work.to_yaml
      
      unless current_user == :false
        @pseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
        to_select = @work.authors.blank? ? @work.pseuds.blank? ? [current_user.default_pseud] : @work.pseuds : @work.authors 
        @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
        @series = current_user.series.uniq 
      end
    rescue
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
  
  # Users must explicitly okay viewing of adult content
  def check_adult_status
    if params[:view_adult]
      session[:adult] = true
    elsif @work && @work.adult_content? &&  !see_adult? 
      render :partial => "adult", :layout => "application"
    end  
  end
	   
  # GET /works
  def index
    # for nested routes
    if !params[:user_id].blank?
      @user = User.find_by_login(params[:user_id])
    elsif !params[:fandom_id].blank?
      @fandom = Tag.find(params[:fandom_id])
    elsif !params[:tag_id].blank?
      @tag = Tag.find(params[:tag_id])
    end

    sort_column = params[:sort_column] == "date" ? "created_at" : params[:sort_column]
    tag_id = params[:tag_id].blank? ? params[:fandom_id] : params[:tag_id]
    @pseuds = params[:pseuds] || []    
    @selected_tags = params[:selected_tags] || {}
    @query = params[:query]

    @works, @filters, error = Work.search_and_filter(
       "sort_column" => sort_column,
       "sort_direction" => params[:sort_direction],
       "user_id" => params[:user_id],
       "tag_id" => tag_id,
       "pseuds" =>@pseuds,
       "query" => @query ,
       "selected_tags" => @selected_tags
      )
    flash[:error] = error unless error.blank?
    @works = @works.paginate(:page => params[:page])
  end
  
  def drafts
    unless params[:user_id]
      flash[:error] = "Whose drafts did you want to look at?".t
      redirect_to :controller => :users, :action => :index
    else
      @user = User.find_by_login(params[:user_id])
      unless current_user == @user
        flash[:error] = "You can only see your own drafts, sorry!".t
        redirect_to current_user
      else
        @works = @user.unposted_works
        @works = @works.paginate(:page => params[:page])
      end
    end
  end 
  
  # GET /works/1
  # GET /works/1.xml
  def show
    unless @work
  	  flash[:error] = 'This page is unavailable.'.t
      redirect_to works_path and return
    end
    unless @work.visible || is_admin?
      if !current_user.is_a?(User)
        store_location 
        redirect_to new_session_path and return        
      elsif !current_user.is_author_of?(@work)
  	    flash[:error] = 'This page is unavailable.'.t
        redirect_to works_path and return
      end
    end
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
    @tag_categories_limited = TagCategory.official - [TagCategory.find_by_name("Warning")]
  end
  
  # GET /works/new
  def new
    if params[:load_unposted] && current_user.unposted_work
      @work = current_user.unposted_work
    elsif params[:upload_work]
      @use_upload_form = true
    end
  end

  # POST /works
  def create
    begin
      raise unless @work.errors.empty?
      if !@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank?
        @work.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
      elsif params[:edit_button]
        render :action => :new
      elsif params[:cancel_coauthor_button]
        render :action => :new
      elsif params[:cancel_button]
        flash[:notice] = "New work posting canceled.".t
        current_user.cleanup_unposted_works
        redirect_to current_user    
      else  
        begin
          saved = @work.save
        rescue ThinkingSphinx::ConnectionError
          saved = true
        end        
        unless saved && @work.has_required_tags?
          unless @work.has_required_tags?
            @work.errors.add(:base, "Required tags are missing.".t)          
          end
          render :action => :new 
        else
          flash[:notice] = 'Work was successfully created.'.t
          redirect_to preview_work_path(@work)
        end
      end
    rescue
      render :action => :new
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
    begin
      raise unless @work.errors.empty?
      @work.attributes = params[:work]    
      # Need to update @pseuds and @selected_pseuds values so we don't lose new co-authors if the form needs to be rendered again
      @pseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
      to_select = @work.authors.blank? ? @work.pseuds.blank? ? [current_user.default_pseud] : @work.pseuds : @work.authors 
      @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }

      if !@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank? 
        @work.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
      elsif params[:preview_button]
        @preview_mode = true
        @chapters = [@chapter]
        if @work.has_required_tags?
          render :action => "preview"
        else
          @work.errors.add_to_base("Please add all required tags.")
          render :action => :edit
        end
      elsif params[:cancel_button]
        flash[:notice] = "This work was not posted. (It will be saved in your drafts for one week, then cleaned up.)".t
        current_user.cleanup_unposted_works
        redirect_to current_user    
      elsif params[:edit_button]
        render :partial => 'work_form', :layout => 'application'
      else
        saved = true
        @chapter.save || saved = false
        @work.has_required_tags? || saved = false
        @work.posted = true 
        begin
          saved = @work.save
          @work.update_minor_version
        rescue ThinkingSphinx::ConnectionError
          saved = true
        end
        if saved
          if params[:post_button]
            flash[:notice] = 'Work was successfully posted.'.t
          elsif params[:update_button]
            flash[:notice] = 'Work was successfully updated.'.t
          end
          redirect_to(@work)
        else
          unless @chapter.valid?
            @chapter.errors.each {|err| @work.errors.add(:base, err)}
          end
          unless @work.has_required_tags?
            @work.errors.add(:base, "Required tags are missing.".t)          
          end
          raise
        end
      end 
    rescue
      render :action => :edit
    end
  end
 
  # GET /works/1/preview
  def preview
    @preview_mode = true
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
    begin
      @work.destroy
    rescue ThinkingSphinx::ConnectionError
      flash[:error] = "We couldn't delete that right now, sorry! Please try again later.".t
      if env['RAILS_ENV'] == 'development'
        flash[:error] += "(Note to developers: this means that the sphinx searchd isn't running. 
                          You can safely ignore this if you are just testing other things.)"
      end
    end
    redirect_to(user_works_url(current_user))
  end

  # POST /works/upload_work
  def upload_work
    storyparser = StoryParser.new
    # Do stuff with params[:uploaded_file]
    # parse the existing work 
    if params[:uploaded_work]
      @work = storyparser.parse_story(params[:uploaded_work])
      render :action => "new"
    elsif params[:work_url]
      url = params[:work_url].to_s
      if url.empty? 
        flash.now[:error] = "Did you want to enter a URL?"
      else
        begin
          @work = storyparser.download_and_parse_story(url)
          @chapter = @work.chapters.first
          @work.pseuds << current_user.default_pseud
          @chapter.pseuds << current_user.default_pseud
          if @chapter.save && @work.save
            flash[:notice] = "Work successfully uploaded!".t + "<br />" +
              "(You will want to check the results over carefully before posting, though, 
                because the poor computer can only figure out so much.)".t
            redirect_to edit_work_path(@work) and return
          else
            render :action => :new and return
          end
        rescue Timeout::Error
          flash.now[:error] = "Sorry, but we timed out trying to get that URL.".t
        rescue
          flash.now[:error] = "Sorry, but we couldn't find a story at that URL. You can still copy-and-paste the contents into our standard form, though!".t
        end
      end
      @use_upload_form = true
      render :action => :new
    else
      @use_upload_form = true
      render :action => :new
    end
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
