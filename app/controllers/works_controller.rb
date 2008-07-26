class WorksController < ApplicationController
  # only registered users and NOT admin should be able to create new works
  before_filter :users_only, :except => [ :index, :show, :destroy, :singlechapter, :allchapters ]
  # only authors of a work should be able to edit it
  before_filter :is_author_true, :only => [ :edit, :update ]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :manage_chapters, :preview, :post, :show ]
  before_filter :update_or_create_reading, :only => [ :show ]
  before_filter :check_permission_to_view, :only => :show
  
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
    flash[:error] = "Please log in first.".t
    store_location
    redirect_to new_session_path
    false
  end

  # Sets values for @work, @chapter, @coauthor_results, @pseuds, and @selected
  def set_instance_variables
    if params[:pseud] && params[:pseud][:byline] && params[:work][:author_attributes]
      params[:work][:author_attributes][:byline] = params[:pseud][:byline]
      params[:pseud][:byline] = ""
    end
    
    if params[:id] # edit, update, preview, post, manage_chapters
      @work = Work.find(params[:id])
    elsif params[:work]  # create
      @work = Work.new(params[:work])
    else # new
      if current_user.unposted_work
        @work = current_user.unposted_work
      else
        @work = Work.new
        @work.chapters.build
      end
    end

    @chapter = @work.first_chapter
    if params[:work] && params[:work][:chapter_attributes]
      @chapter.content = params[:work][:chapter_attributes][:content]
    end
    @chapters = @work.chapters.in_order
    
    unless current_user == :false
      @pseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
      to_select = @work.authors.blank? ? @work.pseuds.blank? ? [current_user.default_pseud] : @work.pseuds : @work.authors 
      @selected = to_select.collect {|pseud| pseud.id.to_i }
      @work.poster = current_user
      @series = current_user.series 
    end
  end
  
  # check if the user's current pseud is one associated with the work
  def is_author
    @work = Work.find(params[:id])
    not (logged_in? && (current_user.pseuds & @work.pseuds).empty?)
  end  
  
  # if is_author returns true allow them to update, otherwise redirect them to the work page with an error message
  def is_author_true
    is_author || [ redirect_to(@work), flash[:error] = 'Sorry, but you don\'t have permission to make edits.'.t ]
  end
  
  # Only logged-in users should be able to access restricted works
  def check_permission_to_view
    @work = Work.find(params[:id])
	  access_denied if !logged_in? && @work.restricted?
  end
   
  # GET /works
  def index
    conditions = "posted = true"
    # Get only works in the current locale
	  conditions << " AND language_id = #{Locale.active.language.id}" if Locale.active && Locale.active.language
    conditions << " AND restricted = 0 OR restricted IS NULL" unless logged_in?
    if params[:user_id]
      @user = User.find_by_login(params[:user_id])
      @works = @user.works
    else
      @works = Work.find(:all, :conditions => conditions, :order => "works.created_at DESC", :include => :pseuds )
    end
  end
  
  # GET /works/1
  # GET /works/1.xml
  def show
    @comments = @work.find_all_comments
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
      redirect_back_or_default('/')    
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
      @work.pseuds = @work.pseuds - current_user.pseuds
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
  
  # PUT /works/1
  def update
    @work.attributes = params[:work]
    
    # Need to update @pseuds and @selected values so we don't lose new co-authors if the form needs to be rendered again
    @pseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
    to_select = @work.authors.blank? ? @work.pseuds.blank? ? [current_user.default_pseud] : @work.pseuds : @work.authors 
    @selected = to_select.collect {|pseud| pseud.id.to_i }
   
    if !@work.invalid_pseuds.blank? || !@work.ambiguous_pseuds.blank? 
      @work.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
    elsif params[:preview_button]
  	  @chapters = [@chapter]
      render :action => "preview"
    elsif params[:cancel_button]
      # Not quite working yet - should send the user back to wherever they were before they hit edit
      redirect_back_or_default('/')
    elsif params[:edit_button]
      render :partial => 'work_form', :layout => 'application'
    else
      begin
        @chapter.save!
        @work.posted = true 
        @work.save!
        @work.update_minor_version
        if params[:post_button]
          flash[:notice] = 'Work was successfully posted.'.t
        elsif params[:update_button]
          flash[:notice] = 'Work was successfully updated.'.t
        end
        redirect_to(@work)
      rescue
        render :partial => 'work_form', :layout => 'application' 
      end
    end 
  end
 
  # GET /works/1/preview
  def preview
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
  
  # Shows single-chapter view on work page
  def singlechapter
    @work = Work.find(params[:id])
    @chapter = @work.first_chapter
    @commentable = @work.first_chapter
    @comments = @chapter.find_all_comments
    respond_to do |format|
      format.js
    end
  end
  
  # Toggles back to showing all chapters
  def allchapters
    @work = Work.find(params[:id])
    @chapters = @work.chapters.in_order
    @comments = @work.find_all_comments
    respond_to do |format|
      format.js
    end
  end
  
  protected

  # create a reading object when showing a work, but only if the user has reading 
  # history enabled and is not the author of the work
  def update_or_create_reading
    if logged_in? && current_user.preference.history_enabled
      unless is_author
        reading = Reading.find_or_initialize_by_work_id_and_user_id(@work.id, current_user.id)
        reading.major_version_read, reading.minor_version_read = @work.major_version, @work.minor_version
        reading.save
      end
    end
    true
  end

end
