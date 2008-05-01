class WorksController < ApplicationController
  # only registered users and NOT admin should be able to create new works
  before_filter :users_only, :except => [ :index, :show, :destroy ]
  # only authors of a work should be able to edit it
  before_filter :is_author_true, :only => [ :edit, :update ]
  
  # check if the user's current pseud is one associated with the work
  def is_author
    @work = Work.find(params[:id])
    
    current_user.pseuds.each do |pseud|
      if pseud.creations.include?(@work)
        return true
      end
    end
    return false
  end  
  
  # if is_author returns true allow them to update, otherwise redirect them to the work page with an error message
  def is_author_true
    is_author || [ redirect_to(@work), flash[:error] = 'Sorry, but you don\'t have permission to make edits.' ]
  end
  
  # GET /works
  def index
    @works = Work.find(:all) 
    
  end
  
  # GET /works/1
  # GET /works/1.xml
  def show
    @work = Work.find(params[:id]) 
    @comments = @work.find_all_comments
    
  end
  
  # GET /works/new
  def new
    @work = Work.new
    @work.chapters.build
    @chapter = @work.chapters.first
    @work.metadata = Metadata.new
    @metadata = @work.metadata
    @pseuds = current_user.pseuds
    @selected = current_user.default_pseud.id 
  end

  # POST /works
  def create
    @work = Work.new(params[:work])
    @chapter = @work.chapters.build params[:chapter_attributes]
    @work.metadata = Metadata.new(params[:metadata_attributes])
    @pseuds = Pseud.get_pseuds_from_params(params[:pseud][:id])
    if @work.save
      Creatorship.add_authors(@work, @pseuds)
      Creatorship.add_authors(@work.chapters.first, @pseuds)
      flash[:notice] = 'Work was successfully created.'
      redirect_to preview_work_path(@work)
    else
      @pseuds = current_user.pseuds
      @selected = params[:pseud][:id]
      render :action => :index 
    end 
  end
  
  # GET /works/1/edit
  def edit
    @work = Work.find(params[:id])
    @chapter = @work.chapters.first
    @chapters = Chapter.find(:all, :conditions => {:work_id => @work.id}, :order => "position")
    @pseuds = @work.pseuds
    @selected = @work.pseuds.collect { |pseud| pseud.id.to_i }
  end
  
  # PUT /works/1
  def update
    @work = Work.find(params[:id])
    if params[:chapter_attributes]
      @work.chapters.first.update_attributes params[:chapter_attributes]
    end
    if params[:metadata_attributes]
      @work.metadata.update_attributes params[:metadata_attributes]
    end
    @pseuds = Pseud.get_pseuds_from_params(params[:pseud][:id], params[:extra_pseuds])
    
    if @work.update_attributes(params[:work])
      Creatorship.add_authors(@work, @pseuds)
      @work.inc_minor_version
      flash[:notice] = 'Work was successfully updated.'
      redirect_to preview_work_path(@work)
    else
      render :action => "edit" 
    end 
  end
 
  # GET /works/1/preview
  def preview
    @work = Work.find(params[:id])
  end
  
  # POST /works/1/post
  def post
    @work = Work.find(params[:id])
    @work.posted = true
    # Will save tags here when tags exist!
    if @work.save
      flash[:notice] = 'Work has been posted!'
      redirect_to(@work)
    else
      render :action => "preview"
    end
  end
  
  # DELETE /works/1
  def destroy
    @work = Work.find(params[:id])
    @work.destroy
    redirect_to(works_url)
  end
  
  def update_positions
    params[:sortable_chapter_list].each_with_index do |id, position|
      Chapter.update(id, :position => position + 1)
    end
    render :nothing => true
  end
  
end
