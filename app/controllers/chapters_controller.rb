class ChaptersController < ApplicationController
  # only registered users and NOT admin should be able to create new chapters
  before_filter :users_only, :except => [ :show, :destroy ]
  before_filter :load_work, :except => [:auto_complete_for_pseud_name, :update_positions]
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :preview, :post ]
  # only authors of a work should be able to edit its chapters
  before_filter :check_ownership, :only => [ :edit, :update, :manage, :destroy ]
  before_filter :check_visibility, :only => [ :show]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
    
  # GET /work/:work_id/chapters
  # GET /work/:work_id/chapters.xml
  def index
    # this route is never used
    redirect_to work_path(params[:work_id])
  end
  
  # GET /work/:work_id/chapters/manage
  def manage
    @chapters = @work.chapters_in_order(false).select(&:posted)
  end
  
  # GET /work/:work_id/chapters/:id
  # GET /work/:work_id/chapters/:id.xml
  def show
    if params[:view_adult]
      session[:adult] = true
    elsif @work.adult? && !see_adult? 
      render :partial => "works/adult", :layout => "application" and return
    end  

    if params[:selected_id]
      redirect_to url_for(:controller => :chapters, :action => :show, :work_id => @work.id, :id => params[:selected_id]) and return
    end
    @chapter = @work.chapters.find(params[:id])
    @chapters = @work.chapters_in_order(false)
    if !logged_in? || !current_user.is_author_of?(@work)
      @chapters = @chapters.select(&:posted)
    end 
    if !@chapters.include?(@chapter)
      access_denied
    else
      if @chapters.length > 1
        chapter_position = @chapters.index(@chapter)
        @previous_chapter = @chapters[chapter_position-1] unless chapter_position == 0
        @next_chapter = @chapters[chapter_position+1]
      end
      @commentable = @work
      @comments = @chapter.comments
      
      @page_title = @work.unrevealed? ? t('works.mystery_chapter_title', :default => "Mystery Work - Chapter {{position}}", :position => @chapter.position.to_s) : 
        get_page_title(@work.fandoms.string, 
          @work.anonymous? ? t('chapters.anonymous', :default => "Anonymous") : @work.pseuds.sort.collect(&:byline).join(', '), 
          @work.title + " - Chapter " + @chapter.position.to_s)
    
      respond_to do |format|
        format.html
        format.js
      end
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
      flash[:notice] = t('removed_as_author', :default => "You have been removed as an author from the chapter")
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
        if @chapter.published_at > @work.revised_at.to_date || @chapter.published_at == Date.today
          @work.set_revised_at(@chapter.published_at)
        end  
        flash[:notice] = t('preview', :default => "This is a preview of what this chapter will look like when it's posted to the Archive. You should probably read the whole thing to check for problems before posting.")
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
      if @work.save && @chapter.save
        @work.update_minor_version
        if defined?(@previous_published_at) && @previous_published_at != @chapter.published_at #if published_at has changed
          if @chapter.published_at == Date.today # if today, set revised_at to this date
            @work.set_revised_at(@chapter.published_at)
          else # if p_at date not today, tell model to find most recent chapter date
            @work.set_revised_at
          end
        end
        flash[:notice] = t('successfully_updated', :default => 'Chapter was successfully updated.')
        redirect_to [@work, @chapter]
      else
        render :action => "edit" 
      end
    end 
  end
  
  def update_positions
    if params[:chapters]
      @work = Work.find(params[:work_id])
      @work.reorder(params[:chapters]) 
      flash[:notice] = t('order_updated', :default => 'Chapter orders have been successfully updated.')
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
      redirect_to @work 
    elsif params[:edit_button]
      redirect_to [:edit, @work, @chapter]
    else
      @chapter.posted = true
      if @chapter.save
        if !@work.posted
          @work.update_attribute(:posted, true)
        end
        flash[:notice] = t('successfully_posted', :default => 'Chapter has been posted!')
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
      flash[:error] = t('deleting_only_chapter', :default => "You can't delete the only chapter in your story. If you want to delete the story, choose 'Delete work'.")
      redirect_to(edit_work_url(@work))
    else
      if @chapter.destroy
        @work.update_minor_version
        @work.set_revised_at
        flash[:notice] = t('successfully_deleted', :default => "The chapter was successfully deleted.")
      else
        flash[:error] = t('delete_failed', :default => "Something went wrong. Please try again.")
      end
      redirect_to :controller => 'works', :action => 'show', :id => @work
    end
  end
  
  private 
  
  def load_pseuds
    @allpseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds + (@chapter.authors ||= []) + (@chapter.pseuds ||= [])).uniq    
    @pseuds = current_user.pseuds
    @coauthors = @allpseuds.select{ |p| p.user.id != current_user.id}
    to_select = @chapter.authors.blank? ? @chapter.pseuds.blank? ? @work.pseuds : @chapter.pseuds : @chapter.authors 
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
  end
  
  # fetch work these chapters belong to from db
  def load_work
    @work = params[:work_id] ? Work.find(params[:work_id]) : Chapter.find(params[:id]).work
    @check_ownership_of = @work
    @check_visibility_of = @work  
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
      @previous_published_at = @chapter.published_at
      if params[:chapter]  # editing, save our changes
        @chapter.attributes = params[:chapter]
      end
    elsif params[:chapter] # create
      @chapter = @work.chapters.build(params[:chapter])
    else # new
      @chapter = @work.chapters.build(:position => @work.number_of_chapters + 1)
    end

    @allpseuds = (current_user.pseuds + (@work.authors ||= []) + @work.pseuds + (@chapter.authors ||= []) + (@chapter.pseuds ||= [])).uniq    
    @pseuds = current_user.pseuds
    @coauthors = @allpseuds.select{ |p| p.user.id != current_user.id}
    to_select = @chapter.authors.blank? ? @chapter.pseuds.blank? ? @work.pseuds : @chapter.pseuds : @chapter.authors 
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
    
  end
  
end
