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
    is_author || [ redirect_to (@work), flash[:error] = 'Sorry, but you don\'t have permission to make edits.' ]
  end
  
  # GET /works
  # GET /works.xml
  def index
    @works = Work.find(:all) 
    
    # This is here just as an example of how to set a flash alert.
    # You can use flash[:notice], flash[:warning], and flash[:error].
    # * flash.now[...] gets used if you are dropping through to the default action or using render.
    # * flash[...] gets used if you are redirecting.
    # flash.now[:notice] = 'This is a sample notice box. It is appearing here only because it has been manually set in the show method in the controller as an example.'
  end
  
  # GET /works/1
  # GET /works/1.xml
  def show
    @work = Work.find(params[:id]) 
    @comments = @work.find_all_comments
    
    # This is here just as an example of how to set a flash alert.
    # You can use flash[:notice], flash[:warning], and flash[:error].
    # * flash.now[...] gets used if you are dropping through to the default action or using render.
    # * flash[...] gets used if you are redirecting.
    # flash.now[:error] = 'This is a sample error box. It is appearing here only because it has been manually set in the show method in the controller as an example.'
  end
  
  # GET /works/new
  # GET /works/new.xml
  def new
    @work = Work.new
    @work.chapters.build
    @work.metadata = Metadata.new
    @pseuds = current_user.pseuds
    @selected = current_user.default_pseud.id
  end
  
  # GET /works/1/edit
  def edit
    @work = Work.find(params[:id])
    @pseuds = @work.pseuds
    @selected = @work.pseuds.collect { |pseud| pseud.id.to_i }
  end
  
  # POST /works
  # POST /works.xml
  def create
    @work = Work.new(params[:work])
    @chapter = @work.chapters.build params[:chapter_attributes]
    @work.metadata = Metadata.new(params[:metadata_attributes])
    
    # Display the collected data if we're in preview mode, save it if we're not
    if params[:preview_button] && !params[:create_button]
      @pseuds = Pseud.get_pseuds_from_params(params[:pseud][:id], params[:extra_pseuds])
      @selected = @pseuds.collect { |pseud| pseud.id.to_i }
      render :partial => 'work_view', :layout => 'application'
    else 
      @pseuds = Pseud.get_pseuds_from_params(params[:pseud][:id])
      if @work.save
        Creatorship.add_authors(@work, @pseuds)
        Creatorship.add_authors(@work.chapters.first, @pseuds)
        flash[:notice] = 'Work was successfully created.'
        redirect_to(@work)
      else
        render :action => "new" 
      end 
    end
  end
  
  # PUT /works/1
  # PUT /works/1.xml
  def update
    @work = Work.find(params[:id])
    @work.chapters.update params[:chapter_attributes].keys, params[:chapter_attributes].values
    @work.metadata.update_attributes params[:metadata_attributes]
    @pseuds = Pseud.get_pseuds_from_params(params[:pseud][:id], params[:extra_pseuds])
    
    if @work.update_attributes(params[:work])
      Creatorship.add_authors(@work, @pseuds)
      flash[:notice] = 'Work was successfully updated.'
      redirect_to(@work)
    else
      render :action => "edit" 
    end 
  end
  
  # DELETE /works/1
  # DELETE /works/1.xml
  def destroy
    @work = Work.find(params[:id])
    @work.destroy
    redirect_to(works_url)
  end
end
