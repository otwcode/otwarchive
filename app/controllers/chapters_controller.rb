class ChaptersController < ApplicationController
  # only registered users and NOT admin should be able to create new chapters
  before_filter :users_only, :except => [ :index, :show, :destroy ]
  before_filter :load_work, :except => [:auto_complete_for_pseud_name, :update_positions]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :preview, :post ]
  # only authors of a work should be able to edit its chapters
  before_filter :is_author, :only => [ :edit, :update, :manage ]
  before_filter :check_permission_to_view, :only => [:index, :show]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
  
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
    
  # Only authors of the work should be able to edit it
  def is_author
    @work = Work.find(params[:work_id])
    unless current_user.is_a?(User) && current_user.is_author_of?(@work)
      flash[:error] = "Sorry, but you don't have permission to make edits.".t
      redirect_to(@work)     
    end
  end 
  
  # Only authorized users should be able to access restricted/hidden works
  def check_permission_to_view
    can_view_hidden = is_admin? || (current_user.is_a?(User) && current_user.is_author_of?(@work))
	  access_denied if (!is_registered_user? && @work.restricted?) || (!can_view_hidden && @work.hidden_by_admin?)
  end
  
  # fetch work these chapters belong to from db
  def load_work
    @work = params[:work_id] ? Work.find(params[:work_id]) : Chapter.find(params[:id]).work  
  end
  
  # Sets values for @chapter, @coauthor_results, @pseuds, and @selected_pseuds
  def set_instance_variables
    if params[:pseud] && params[:pseud][:byline] && params[:chapter][:author_attributes]
      params[:chapter][:author_attributes][:byline] = params[:pseud][:byline]
      params[:pseud][:byline] = ""
    end
    
    if params[:id] # edit, update, preview, post
      @chapter = @work.chapters.find(params[:id])
    elsif params[:chapter] # create
      @chapter = @work.chapters.build(params[:chapter])
    else # new
      @chapter = current_user.unposted_chapter(@work) || @work.chapters.build
    end
    
    @pseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds).uniq
    to_select = @chapter.authors.blank? ? @chapter.pseuds.blank? ? @work.pseuds : @chapter.pseuds : @chapter.authors 
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
    
  end
  
  # GET /work/:work_id/chapters
  # GET /work/:work_id/chapters.xml
  def index
    @chapters = @work.chapters.find(:all, :conditions => {:posted => true}, :order => "position")
    if @chapters.empty?
      flash[:notice] = "That work has no posted chapters".t
      redirect_to ('/') and return
    end
    @old_chapter = params[:old_chapter] ? @work.chapters.find(params[:old_chapter]) : @work.first_chapter 
    @commentable = @work
    @comments = @work.find_all_comments
    @tag_categories = TagCategory.official
    respond_to do |format|
      format.html { render :template => "works/show" }
      format.js
    end
  end
  
  # GET /work/:work_id/chapters/manage
  def manage
    @chapters = @work.chapters.find(:all, :conditions => {:posted => true}, :order => "position")                    
  end
  
  # GET /work/:work_id/chapters/1
  # GET /work/:work_id/chapters/1.xml
  def show
    @chapter = @work.chapters.find(params[:id])
    @chapters = [@chapter]
    @commentable = @work
    @tag_categories = TagCategory.official
    if !@work.visible(current_user)
      render :file => "#{RAILS_ROOT}/public/403.html",  :status => 403 and return
    elsif @work.adult? && !see_adult?
      @back = request.env["HTTP_REFERER"]
      @back = root_path unless @back
      if @back == work_chapter_url(@work, @chapter)
        session[:adult] = true
      else
        render :action => "adult" and return
      end
    end
    @comments = @chapter.comments
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  # GET /work/:work_id/chapters/new
  # GET /work/:work_id/chapters/new.xml
  def new 
  end
  
  # GET /work/:work_id/chapters/1/edit
  def edit
    if params["remove"] == "me"
      @chapter.pseuds = @chapter.pseuds - current_user.pseuds
      @chapter.save
      flash[:notice] = "You have been removed as an author from the chapter".t
      redirect_to @work
    end
  end
  
  # POST /work/:work_id/chapters
  # POST /work/:work_id/chapters.xml
  def create
  	@work.wip_length = params[:chapter][:wip_length]
  
    if !@chapter.invalid_pseuds.blank? || !@chapter.ambiguous_pseuds.blank?
      @chapter.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
    elsif params[:edit_button]
      render :action => :new
    elsif params[:cancel_button]
      redirect_back_or_default('/')    
    else  
      if @chapter.save! && @work.save!
        @work.update_major_version
				@chapter.move_to(@chapter.position_placeholder) if @chapter.position_placeholder
        flash[:notice] = "This is a preview of what this chapter will look like when it's posted to the Archive. You should probably read the whole thing to check for problems before posting.".t
        redirect_to [:preview, @work, @chapter]
      else
        render :action => :new 
      end
    end
  end    
  
  # PUT /work/:work_id/chapters/1
  # PUT /work/:work_id/chapters/1.xml
  def update
   
    @chapter.attributes = params[:chapter]
    @work.wip_length = params[:chapter][:wip_length]

    if !@chapter.invalid_pseuds.blank? || !@chapter.ambiguous_pseuds.blank?
      @chapter.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
    elsif params[:preview_button]
      render :partial => 'preview_edit', :layout => 'application'
    elsif params[:cancel_button]
      # Not quite working yet - should send the user back to wherever they were before they hit edit
      redirect_back_or_default('/')
    elsif params[:edit_button]
      render :action => "edit"
    else
	  params[:chapter][:posted] = true if params[:post_button]
      if @chapter.update_attributes(params[:chapter]) && @work.save
        @work.update_minor_version      
        @chapter.move_to(@chapter.position_placeholder) if @chapter.position_placeholder
        flash[:notice] = 'Chapter was successfully updated.'.t
        redirect_to [@work, @chapter]
      else
        render :action => "edit" 
      end
    end 
  end
  
  def update_positions
    if params[:chapters]
      @work = Work.find(params[:work_id])
      @work.reorder_chapters(params[:chapters]) 
      flash[:notice] = 'Chapter orders have been successfully updated.'.t
      redirect_to(@work)
    else 
      params[:sortable_chapter_list].each_with_index do |id, position|
        Chapter.update(id, :position => position + 1)
        (@chapters ||= []) << Chapter.find(id)
      end
    end
  end 
  
  # GET /chapters/1/preview
  def preview
  end
  
  # POST /chapters/1/post
  def post
    if params[:cancel_button]
      redirect_back_or_default('/') 
    elsif params[:edit_button]
      redirect_to [:edit, @work, @chapter]
    else
      @chapter.posted = true
      if @chapter.save
        flash[:notice] = 'Chapter has been posted!'.t
        redirect_to(@work)
      else
        render :action => "preview"
      end
    end
  end
  
  # DELETE /work/:work_id/chapters/1
  # DELETE /work/:work_id/chapters/1.xml
  def destroy
    @chapter = @work.chapters.find(params[:id])
    if @chapter.is_only_chapter?
      flash[:error] = "You can't delete the only chapter in your story. If you want to delete the story, choose 'Delete work'.".t
      redirect_to(edit_work_url(@work))
    else
      @chapter.destroy
      @work.adjust_chapters(@chapter.position)
      @work.update_minor_version
      redirect_to(edit_work_url(@work))
    end
  end
end
