class ChaptersController < ApplicationController
  # only registered users and NOT admin should be able to create new chapters
  before_filter :users_only, :except => [ :index, :show, :destroy ]
  before_filter :load_work, :except => :auto_complete_for_pseud_name
  before_filter :set_instance_variables, :only => [ :new, :create, :edit, :update, :preview, :post ]
  # only authors of a chapter should be able to edit it
  # should actually be that all authors of a work should be able to edit all chapters
  before_filter :is_author_true, :only => [ :edit, :update ] 
  
  auto_complete_for :pseud, :name
  
  # check if the user's current pseud is one associated with the chapter
  def is_author
    @work = Work.find(params[:work_id])
    @chapter = @work.chapters.find(params[:id])
    
    current_user.pseuds.each do |pseud|
      if pseud.creations.include?(@chapter)
        return true
      end
    end
    return false
  end  
  
  # if is_author returns true allow them to update, otherwise redirect them to the work page with an error message
  def is_author_true
    is_author || [ redirect_to(@work), flash[:error] = 'Sorry, but you don\'t have permission to make edits.' ]
  end
  
  # fetch work these chapters belong to from db
  def load_work
    @work = Work.find(params[:work_id])    
  end
  
  # Sets values for @chapter, @pseuds, and @selected
  def set_instance_variables
    if params[:id] # edit, update, preview, post
      @chapter = @work.chapters.find(params[:id])
    elsif params[:chapter] # create
      @chapter = @work.chapters.build(params[:chapter])
    else # new
      @chapter = @work.chapters.build
      @chapter.metadata = Metadata.new
    end
    
    @pseuds = @work.pseuds
    
    if params[:chapter] && params[:chapter]["author_attributes"] && params[:chapter]["author_attributes"]["ids"]
      @selected = params[:chapter]["author_attributes"]["ids"].collect {|id| id.to_i }
    elsif @chapter.authors
      @selected = @chapter.authors.collect {|pseud| pseud.id.to_i }
    elsif @chapter.pseuds
      @selected = @chapter.pseuds.collect {|pseud| pseud.id.to_i }  
    else
      @selected = @work.pseuds.collect {|pseud| pseud.id.to_i }
    end  
  end
  
  # GET /work/:work_id/chapters
  # GET /work/:work_id/chapters.xml
  def index 
    @chapters = Chapter.find(:all, :conditions => {:work_id => @work.id}, :order => "position")
    @comments = @work.find_all_comments
  end
  
  # GET /work/:work_id/chapters/1
  # GET /work/:work_id/chapters/1.xml
  def show
    @chapter = @work.chapters.find(params[:id])
    @comments = @chapter.find_all_comments
  end
  
  # GET /work/:work_id/chapters/new
  # GET /work/:work_id/chapters/new.xml
  def new
  end
  
  # GET /work/:work_id/chapters/1/edit
  def edit
  end
  
  # POST /work/:work_id/chapters
  # POST /work/:work_id/chapters.xml
  def create
    if @chapter.save
      @work.update_major_version
      flash[:notice] = 'This is a preview of what this chapter will look like when it\'s posted to the Archive. You should probably read the whole thing to check for problems before posting.'
      redirect_to [:preview, @work, @chapter]
    else
      render :action => "new" 
    end 
  end
  
  # PUT /work/:work_id/chapters/1
  # PUT /work/:work_id/chapters/1.xml
  def update
    @chapter.attributes = params[:chapter]
    @chapter.work.update_attributes params[:work_attributes] 

    # Display the collected data if we're in preview mode, save it if we're not
    if params[:preview_button]
      @pseuds = (@chapter.authors + @work.pseuds).uniq
      @selected = @chapter.authors.collect {|pseud| pseud.id.to_i }
      render :partial => 'preview_edit', :layout => 'application'
    elsif params[:cancel_button]
      # Not quite working yet - should send the user back to wherever they were before they hit edit
      redirect_back_or_default('/')
    elsif params[:edit_button]
      render :action => "edit"
    else
      if @chapter.update_attributes(params[:chapter])
        @work.update_minor_version
        flash[:notice] = 'Chapter was successfully updated.'
        redirect_to [@work, @chapter]
      else
        render :action => "edit" 
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
    else
      @chapter.posted = true
      # Will save tags here when tags exist!
      if @chapter.save
        flash[:notice] = 'Chapter has been posted!'
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
      flash[:error] = "You can't delete the only chapter in your story. If you want to delete the story, choose 'Delete work'."
      redirect_to(edit_work_url(@work))
    else
      @chapter.destroy
      @work.adjust_chapters(@chapter.position)
      @work.update_minor_version
      redirect_to(edit_work_url(@work))
    end
  end
end
