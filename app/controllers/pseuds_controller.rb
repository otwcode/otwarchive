class PseudsController < ApplicationController
  # GET /pseuds
  # GET /pseuds.xml
  def index
    @pseuds = Pseud.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pseuds }
    end
  end

  # GET /pseuds/1
  # GET /pseuds/1.xml
  def show
    @pseud = Pseud.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pseud }
    end
  end

  # GET /pseuds/new
  # GET /pseuds/new.xml
  def new
    @pseud = Pseud.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pseud }
    end
  end

  # GET /pseuds/1/edit
  def edit
    @pseud = Pseud.find(params[:id])
  end

  # POST /pseuds
  # POST /pseuds.xml
  def create
    @pseud = Pseud.new(params[:pseud])

    respond_to do |format|
      if @pseud.save
        flash[:notice] = 'Pseud was successfully created.'
        format.html { redirect_to(@pseud) }
        format.xml  { render :xml => @pseud, :status => :created, :location => @pseud }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pseud.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pseuds/1
  # PUT /pseuds/1.xml
  def update
    @pseud = Pseud.find(params[:id])

    respond_to do |format|
      if @pseud.update_attributes(params[:pseud])
        flash[:notice] = 'Pseud was successfully updated.'
        format.html { redirect_to(@pseud) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pseud.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pseuds/1
  # DELETE /pseuds/1.xml
  def destroy
    @pseud = Pseud.find(params[:id])
    @pseud.destroy

    respond_to do |format|
      format.html { redirect_to(pseuds_url) }
      format.xml  { head :ok }
    end
  end
end
