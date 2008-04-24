class ChaptersController < ApplicationController
  # only registered users and NOT admin should be able to create new chapters
  before_filter :users_only, :except => [ :index, :show, :destroy ]  
  before_filter :load_work
  # only authors of a chapter should be able to edit it
  # should actually be that all authors of a work should be able to edit all chapters
  before_filter :is_author_true, :only => [ :edit, :update ]
  
  # check if the user's current pseud is one associated with the chapter
  def is_author
    @work = Work.find(params[:id])
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
    is_author || [ redirect_to (@work), flash[:error] = 'Sorry, but you don\'t have permission to make edits.' ]
  end
  
  # fetch work these chapters belong to from db
  def load_work
    #@work = Work.find(params[:work_id])
    @work = Work.find(params[:work_id])    
  end
  
  # GET /work/:work_id/chapters
  # GET /work/:work_id/chapters.xml
  def index 
    @chapters = @work.chapters
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
    @chapter = @work.chapters.build
    @chapter.metadata = Metadata.new
    @pseuds = current_user.pseuds
    @selected = current_user.default_pseud.id
  end
  
  # GET /work/:work_id/chapters/1/edit
  def edit
    @chapter = @work.chapters.find(params[:id])
    @pseuds = @work.pseuds
    @selected = @chapter.pseuds.collect { |pseud| pseud.id.to_i }
  end
  
  # POST /work/:work_id/chapters
  # POST /work/:work_id/chapters.xml
  def create
    @chapter = @work.chapters.build(params[:chapter])
    @chapter.metadata = Metadata.new(params[:metadata_attributes]) 
    
    # Display the collected data if we're in preview mode, save it if we're not
    if params[:preview_button] && !params[:create_button]
      @pseuds = Pseud.get_pseuds_from_params(params[:pseud][:id], params[:extra_pseuds])
      @selected = @pseuds.collect { |pseud| pseud.id.to_i }
      render :partial => 'chapter_view', :layout => 'application'
    else 
      @pseuds = Pseud.get_pseuds_from_params(params[:pseud][:id])
      if @chapter.save
        Creatorship.add_authors(@chapter, @pseuds)
        Creatorship.add_authors(@work, @pseuds)
        flash[:notice] = 'Chapter was successfully created.'
        redirect_to([@work, @chapter])
      else
        render :action => "new" 
      end 
    end
  end
  
  # PUT /work/:work_id/chapters/1
  # PUT /work/:work_id/chapters/1.xml
  def update
    @chapter = @work.chapters.find(params[:id])
    @chapter.work.update_attributes params[:work_attributes] 
    
    if @chapter.metadata
      @chapter.metadata.update_attributes params[:metadata_attributes]
    else
      @chapter.metadata = Metadata.new(params[:metadata_attributes])
    end
    
    @pseuds = Pseud.get_pseuds_from_params(params[:pseud][:id], params[:extra_pseuds])
    
    if @chapter.update_attributes(params[:chapter])
      Creatorship.add_authors(@chapter, @pseuds)
      flash[:notice] = 'Chapter was successfully updated.'
      redirect_to([@work, @chapter])
    else
      render :action => "edit" 
    end 
  end
  
  # DELETE /work/:work_id/chapters/1
  # DELETE /work/:work_id/chapters/1.xml
  def destroy
    @chapter = @work.chapters.find(params[:id])
    @chapter.destroy
    @work.adjust_chapters(@chapter.position)
    redirect_to(work_chapters_url)
  end
end
