class RelatedWorksController < ApplicationController
  # GET /related_works
  # GET /related_works.xml
  def index
    @related_works = RelatedWork.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @related_works }
    end
  end

  # GET /related_works/1
  # GET /related_works/1.xml
  def show
    @related_work = RelatedWork.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @related_work }
    end
  end

  # GET /related_works/new
  # GET /related_works/new.xml
  def new
    @related_work = RelatedWork.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @related_work }
    end
  end

  # GET /related_works/1/edit
  def edit
    @related_work = RelatedWork.find(params[:id])
  end

  # POST /related_works
  # POST /related_works.xml
  def create
    @related_work = RelatedWork.new(params[:related_work])

    respond_to do |format|
      if @related_work.save
        flash[:notice] = 'RelatedWork was successfully created.'
        format.html { redirect_to(@related_work) }
        format.xml  { render :xml => @related_work, :status => :created, :location => @related_work }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @related_work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /related_works/1
  # PUT /related_works/1.xml
  def update
    @related_work = RelatedWork.find(params[:id])

    respond_to do |format|
      if @related_work.update_attributes(params[:related_work])
        flash[:notice] = 'RelatedWork was successfully updated.'
        format.html { redirect_to(@related_work) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @related_work.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /related_works/1
  # DELETE /related_works/1.xml
  def destroy
    @related_work = RelatedWork.find(params[:id])
    @related_work.destroy

    respond_to do |format|
      format.html { redirect_to(related_works_url) }
      format.xml  { head :ok }
    end
  end
end
