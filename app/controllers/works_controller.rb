class WorksController < ApplicationController
  # only registered users and NOT admin should be able to create new works
  before_filter :users_only, :except => [ :index, :show, :destroy ]
  # only authors of a work should be able to edit it
  before_filter :is_author_true, :only => [ :edit, :update ]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :manage_chapters, :preview, :post, :show ]
  before_filter :update_or_create_reading, :only => [ :show ]
  before_filter :check_permission_to_view, :only => :show
  
  auto_complete_for :pseud, :name
  
  def access_denied
    flash[:error] = "Please log in first."
    store_location
    redirect_to new_session_path
    false
  end

  # Sets values for @work, @chapter, @metadata, @coauthor_results, @pseuds, and @selected
  def set_instance_variables
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
        @work.metadata = Metadata.new
      end
    end

    @chapter = @work.chapters.first
    if params[:work] && params[:work][:chapter_attributes]
      @chapter.content = params[:work][:chapter_attributes][:content]
    end
    @chapters = @work.chapters.find(:all, :order => 'position')
    @metadata = @work.metadata
    
    if params[:work] && params[:work][:author_attributes] && !params[:work][:author_attributes][:name].blank?
      @coauthor_results = Pseud.get_coauthor_hash(params[:work][:author_attributes][:name])
    end
    
    unless current_user == :false
      @pseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
      to_select = @work.authors.blank? ? @work.pseuds.blank? ? [current_user.default_pseud] : @work.pseuds : @work.authors 
      @selected = to_select.collect {|pseud| pseud.id.to_i } 
    end
  end
  
  # check if the user's current pseud is one associated with the work
  def is_author
    @work = Work.find(params[:id])
    not (logged_in? && (current_user.pseuds & @work.pseuds).empty?)
  end  
  
  # if is_author returns true allow them to update, otherwise redirect them to the work page with an error message
  def is_author_true
    is_author || [ redirect_to(@work), flash[:error] = 'Sorry, but you don\'t have permission to make edits.' ]
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
    @works = Work.find(:all, :conditions => conditions, :order => "works.created_at DESC", :include => [:pseuds, :metadata] )
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
    @work.set_initial_version     
    
    if params[:no_script] && !(@coauthor_results ||= {}).blank?
      if @work.valid?
        render :partial => 'choose_coauthor', :layout => 'application'
      else
        render :action => :new
      end
    elsif params[:edit_button]
      render :action => :new
    elsif params[:cancel_button]
      redirect_back_or_default('/')    
    else  
      if @work.save
        flash[:notice] = 'Work was successfully created.'
        redirect_to preview_work_path(@work)
      else
        render :action => :new 
      end
    end
  end
  
  # GET /works/1/edit
  def edit
  end
  
  # PUT /works/1
  def update
    @work.attributes = params[:work]
   
    if params[:no_script] && !(@coauthor_results ||= {}).blank? 
      if @work.valid?
        render :partial => 'choose_coauthor', :layout => 'application'
      else
        render :partial => 'work_form', :layout => 'application'
      end
    elsif params[:preview_button]
  	  @chapters = [@chapter]
      render :partial => 'preview_edit', :layout => 'application'
    elsif params[:cancel_button]
      # Not quite working yet - should send the user back to wherever they were before they hit edit
      redirect_back_or_default('/')
    elsif params[:edit_button]
      render :partial => 'work_form', :layout => 'application'
    else
	    params[:work][:posted] = true if params[:post_button]
      if @work.update_attributes(params[:work]) && @chapter.save
        @work.update_minor_version
        flash[:notice] = 'Work was successfully updated.'
        redirect_to(@work)
      else
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
      tagstring = ""
      ["fandoms", "ratings", "warnings", "characters", "freeforms"].each do |kind|
        tagstring = params[kind] + ', ' + tagstring
        Label.create_tags(params[kind], kind)
      end
      @work.posted = true
      @work.chapters.first.posted = true
      if @work.tag_with(tagstring) && @work.save && @work.chapters.first.save
        flash[:notice] = 'Work has been posted!'
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
      unless is_author
        reading = Reading.find_or_initialize_by_work_id_and_user_id(@work.id, current_user.id)
        reading.major_version_read, reading.minor_version_read = @work.major_version, @work.minor_version
        reading.save
      end
    end
    true
  end

end
