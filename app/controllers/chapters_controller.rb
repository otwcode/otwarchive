class ChaptersController < ApplicationController
  before_filter :load_work

  # fetch work these chapters belong to from db
  def load_work
    @work = Work.find(params[:work_id])
  end

  # GET /work/:work_id/chapters
  # GET /work/:work_id/chapters.xml
  def index
    @chapters = @work.chapters.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @chapters }
    end
  end

  # GET /work/:work_id/chapters/1
  # GET /work/:work_id/chapters/1.xml
  def show
    @chapter = @work.chapters.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @chapter }
    end
  end

  # GET /work/:work_id/chapters/new
  # GET /work/:work_id/chapters/new.xml
  def new
    @chapter = @work.chapters.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @chapter }
    end
  end

  # GET /work/:work_id/chapters/1/edit
  def edit
    @chapter = @work.chapters.find(params[:id])
  end

  # POST /work/:work_id/chapters
  # POST /work/:work_id/chapters.xml
  def create
    @chapter = @work.chapters.build(params[:chapter])

    respond_to do |format|
      if @chapter.save
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

    respond_to do |format|
      if @chapter.update_attributes(params[:chapter])
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

    respond_to do |format|
      format.html { redirect_to(work_chapters_url) }
      format.xml  { head :ok }
    end
  end
end
