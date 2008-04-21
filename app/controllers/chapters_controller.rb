class ChaptersController < ApplicationController
  # only registered users and NOT admin should be able to create new chapters
  before_filter :users_only, :except => [ :index, :show, :destroy ]  
  before_filter :load_work

  # fetch work these chapters belong to from db
  def load_work
    @work = Work.find(params[:work_id])
  end

  # GET /work/:work_id/chapters
  # GET /work/:work_id/chapters.xml
  def index 
    @chapters = @work.chapters

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @chapters }
    end
  end

  # GET /work/:work_id/chapters/1
  # GET /work/:work_id/chapters/1.xml
  def show
    @chapter = @work.chapters.find(params[:id])
    @comments = @chapter.find_all_comments

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @chapter }
    end
  end

  # GET /work/:work_id/chapters/new
  # GET /work/:work_id/chapters/new.xml
  def new
    @chapter = @work.chapters.build
    @chapter.metadata = Metadata.new
    @pseud = current_user.default_pseud

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @chapter }
    end
  end

  # GET /work/:work_id/chapters/1/edit
  def edit
    @chapter = @work.chapters.find(params[:id])
    @pseud = current_user.default_pseud
  end

  # POST /work/:work_id/chapters
  # POST /work/:work_id/chapters.xml
  def create
    @chapter = @work.chapters.build(params[:chapter])
    @chapter.metadata = Metadata.new(params[:metadata_attributes]) 
    @pseuds = Pseud.parse_extra_pseuds(params[:extra_pseuds])
    pseud_ids = params[:pseud][:id]
    for pseud_id in pseud_ids
      @pseuds << Pseud.find(pseud_id)
    end

    respond_to do |format|
      if @chapter.save 
        
        for pseud in @pseuds
          author = Pseud.find(pseud)
          author.add_creations(@chapter)
          unless @work.pseuds.include?(author)
            author.add_creations(@work)
          end
        end
        
        flash[:notice] = 'Chapter was successfully created.'
        format.html { redirect_to([@work, @chapter]) }
        format.xml  { render :xml => [@work, @chapter], :status => :created, :location => [@work, @chapter] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @chapter.errors, :status => :unprocessable_entity }
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
    
    @pseuds = Pseud.parse_extra_pseuds(params[:extra_pseuds])
    pseud_ids = params[:pseud][:id]
    for pseud_id in pseud_ids
      @pseuds << Pseud.find(pseud_id)
    end

    respond_to do |format|
      if @chapter.update_attributes(params[:chapter])
        
        for pseud in @pseuds
          unless @chapter.pseuds.include?(pseud)
            pseud.add_creations(@chapter)
          end
        end
        
        flash[:notice] = 'Chapter was successfully updated.'
        format.html { redirect_to([@work, @chapter]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @chapter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work/:work_id/chapters/1
  # DELETE /work/:work_id/chapters/1.xml
  def destroy
    @chapter = @work.chapters.find(params[:id])
    @chapter.destroy
    @work.adjust_chapters(@chapter.position)

    respond_to do |format|
      format.html { redirect_to(work_chapters_url) }
      format.xml  { head :ok }
    end
  end
end
