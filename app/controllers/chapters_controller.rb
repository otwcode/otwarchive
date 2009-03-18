class ChaptersController < ApplicationController
  # only registered users and NOT admin should be able to create new chapters
  before_filter :users_only, :except => [ :index, :show, :destroy ]
  before_filter :load_work, :except => [:auto_complete_for_pseud_name, :update_positions]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :preview, :post ]
  # only authors of a work should be able to edit its chapters
  before_filter :is_author, :only => [ :edit, :update, :manage ]
  before_filter :check_permission_to_view, :only => [:index, :show]
  before_filter :check_adult_status, :only => [:index, :show]
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
    flash[:error] = t('errors.please_log_in', :default => "Please log in first.")
   store_location
    redirect_to new_session_path
    false
  end
    
  # Only authors of the work should be able to edit it
  def is_author
    @work = Work.find(params[:work_id])
    unless current_user.is_a?(User) && current_user.is_author_of?(@work)
      flash[:error] = t('errors.no_permission_to_edit', :default => "Sorry, but you don't have permission to make edits.")
     redirect_to(@work)     
    end
  end 
  
  # Only authorized users should be able to access restricted/hidden works
  def check_permission_to_view
    can_view_hidden = is_admin? || (current_user.is_a?(User) && current_user.is_author_of?(@work))
	  access_denied if (!is_registered_user? && @work.restricted?) || (!can_view_hidden && @work.hidden_by_admin?)
  end
  
  # Users must explicitly okay viewing of adult content
  def check_adult_status
    if params[:view_adult]
      session[:adult] = true
    elsif @work.adult? &&  !see_adult? 
      render :partial => "works/adult", :layout => "application"
    end  
  end
  
  # fetch work these chapters belong to from db
  def load_work
    @work = params[:work_id] ? Work.find(params[:work_id]) : Chapter.find(params[:id]).work  
  end
  
  # Sets values for @chapter, @coauthor_results, @pseuds, and @selected_pseuds
  def set_instance_variables
    # stuff new bylines into author attributes to be parsed by the chapter model
    if params[:chapter] && params[:pseud] && params[:pseud][:byline] && params[:chapter][:author_attributes]
      params[:chapter][:author_attributes][:byline] = params[:pseud][:byline]
      params[:pseud][:byline] = ""
    end

    # stuff co-authors into author attributes too so we won't lose them
    if params[:chapter] && params[:chapter][:author_attributes] && params[:chapter][:author_attributes][:coauthors]
      params[:chapter][:author_attributes][:ids].concat(params[:chapter][:author_attributes][:coauthors]).uniq!
    end
    
    if params[:id] # edit, update, preview, post
      @chapter = @work.chapters.find(params[:id])
      if params[:chapter]  # editing, save our changes
        @chapter.attributes = params[:chapter]
      end
    elsif params[:chapter] # create
      @chapter = @work.chapters.build(params[:chapter])
    else # new
      @chapter = @work.chapters.build
    end

    @allpseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds + (@chapter.authors ||= []) + (@chapter.pseuds ||= [])).uniq    
    @pseuds = current_user.pseuds
    @coauthors = @allpseuds.select{ |p| p.user.id != current_user.id}
    to_select = @chapter.authors.blank? ? @chapter.pseuds.blank? ? @work.pseuds : @chapter.pseuds : @chapter.authors 
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
    
  end
  
  # GET /work/:work_id/chapters
  # GET /work/:work_id/chapters.xml
  def index
    @chapters = @work.chapters.find(:all, :conditions => {:posted => true}, :order => "position")
    if @chapters.empty?
      flash[:notice] = t('errors.chapters.none_posted', :default => "That work has no posted chapters")
     redirect_to ('/') and return
    end
    @old_chapter = params[:old_chapter] ? @work.chapters.find(params[:old_chapter]) : @work.first_chapter 
    @commentable = @work
    @comments = @work.find_all_comments
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
    unless @work.visible || is_admin?
      if !current_user.is_a?(User)
        store_location 
        redirect_to new_session_path and return        
      elsif !current_user.is_author_of?(@work)
  	    flash[:error] = t('errors.chapters.not_visible', :default => 'This page is unavailable.')
       redirect_to works_path and return
      end
    end
    @chapter = @work.chapters.find(params[:id])
    @chapters = [@chapter]
    @commentable = @work
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
      flash[:notice] = t('notices.chapters.removed_as_author', :default => "You have been removed as an author from the chapter")
     redirect_to @work
    end
  end
  
  # POST /work/:work_id/chapters
  # POST /work/:work_id/chapters.xml
  def create
  	@work.wip_length = params[:chapter][:wip_length]
    load_pseuds
    
    if !@chapter.invalid_pseuds.blank? || !@chapter.ambiguous_pseuds.blank?
      @chapter.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
    elsif params[:edit_button]
      render :action => :new
    elsif params[:cancel_button]
      redirect_back_or_default('/')    
    else  # :preview or :cancel_coauthor_button
      if @chapter.save && @work.save
        @work.update_major_version
        @work.set_revised_at(@chapter.created_at)
				@chapter.move_to(@chapter.position_placeholder) if @chapter.position_placeholder
        flash[:notice] = t('notices.chapters.preview', :default => "This is a preview of what this chapter will look like when it's posted to the Archive. You should probably read the whole thing to check for problems before posting.")
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
    load_pseuds
    
    if !@chapter.invalid_pseuds.blank? || !@chapter.ambiguous_pseuds.blank?
      @chapter.valid? ? (render :partial => 'choose_coauthor', :layout => 'application') : (render :action => :new)
    elsif params[:preview_button] || params[:cancel_coauthor_button]
      @preview_mode = true # Enigel Jan 31
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
        flash[:notice] = t('notices.chapters.successfully_updated', :default => 'Chapter was successfully updated.')
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
      flash[:notice] = t('notices.chapters.order_updated', :default => 'Chapter orders have been successfully updated.')
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
    @preview_mode = true #Enigel Jan 31
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
        flash[:notice] = t('notices.chapters.posted', :default => 'Chapter has been posted!')
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
      flash[:error] = t('errors.chapters.deleting_only_chapter', :default => "You can't delete the only chapter in your story. If you want to delete the story, choose 'Delete work'.")
      redirect_to(edit_work_url(@work))
    else
      @chapter.destroy
      @work.adjust_chapters(@chapter.position)
      @work.update_minor_version
      redirect_to(edit_work_url(@work))
    end
  end
  
  def load_pseuds
    @allpseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds + (@chapter.authors ||= []) + (@chapter.pseuds ||= [])).uniq    
    @pseuds = current_user.pseuds
    @coauthors = @allpseuds.select{ |p| p.user.id != current_user.id}
    to_select = @chapter.authors.blank? ? @chapter.pseuds.blank? ? @work.pseuds : @chapter.pseuds : @chapter.authors 
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
  end
end
