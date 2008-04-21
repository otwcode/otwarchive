class WorksController < ApplicationController
  # only registered users and NOT admin should be able to create new works
  before_filter :users_only, :except => [ :index, :show, :destroy ]
  
  
  # GET /works
  # GET /works.xml
  def index
    @works = Work.find(:all) 
    
    # This is here just as an example of how to set a flash alert.
    # You can use flash[:notice], flash[:warning], and flash[:error].
    # * flash.now[...] gets used if you are dropping through to the default action or using render.
    # * flash[...] gets used if you are redirecting.
    # flash.now[:notice] = 'This is a sample notice box. It is appearing here only because it has been manually set in the show method in the controller as an example.'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @works }
    end
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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @work }
    end
  end

  # GET /works/new
  # GET /works/new.xml
  def new
    @work = Work.new
    @work.chapters.build
    @work.metadata = Metadata.new
    @pseud = current_user.default_pseud
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @work }
    end
  end

  # GET /works/1/edit
  def edit
    @work = Work.find(params[:id])
    @pseud = current_user.default_pseud
  end

  # POST /works
  # POST /works.xml
  def create
    @work = Work.new(params[:work])
    @chapter = @work.chapters.build params[:chapter_attributes]
    @work.metadata = Metadata.new(params[:metadata_attributes])
    @pseuds = Pseud.parse_extra_pseuds(params[:extra_pseuds])
    pseud_ids = params[:pseud][:id]
    for pseud_id in pseud_ids
      @pseuds << Pseud.find(pseud_id)
    end

    respond_to do |format|
      if @work.save
        
        for pseud in @pseuds
          pseud.add_creations(@work)
          pseud.add_creations(@work.chapters.first)
        end

        flash[:notice] = 'Work was successfully created.'
        format.html { redirect_to(@work) }
        format.xml  { render :xml => @work, :status => :created, :location => @work }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /works/1
  # PUT /works/1.xml
  def update
    @work = Work.find(params[:id])
    @work.chapters.update params[:chapter_attributes].keys, params[:chapter_attributes].values
    @work.metadata.update_attributes params[:metadata_attributes]
    @pseuds = Pseud.parse_extra_pseuds(params[:extra_pseuds])
    pseud_ids = params[:pseud][:id]
    for pseud_id in pseud_ids
      @pseuds << Pseud.find(pseud_id)
    end

    respond_to do |format|
      if @work.update_attributes(params[:work])
        
        for pseud in @pseuds
          unless @work.pseuds.include?(pseud)
            pseud.add_creations(@work)
          end
        end
        
        flash[:notice] = 'Work was successfully updated.'
        format.html { redirect_to(@work) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work.errors, :status => :unprocessable_entity }
      end
    end
  end
   
  # DELETE /works/1
  # DELETE /works/1.xml
  def destroy
    @work = Work.find(params[:id])
    @work.destroy

    respond_to do |format|
      format.html { redirect_to(works_url) }
      format.xml  { head :ok }
    end
  end
end
