class CatsController < ApplicationController
  # GET /cats
  # GET /cats.xml
  def index
    @cats = Cat.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cats }
    end
  end

  # GET /cats/1
  # GET /cats/1.xml
  def show
    @cat = Cat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cat }
    end
  end

  # GET /cats/new
  # GET /cats/new.xml
  def new
    @cat = Cat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cat }
    end
  end

  # GET /cats/1/edit
  def edit
    @cat = Cat.find(params[:id])
  end

  # POST /cats
  # POST /cats.xml
  def create
    @cat = Cat.new(params[:cat])

    respond_to do |format|
      if @cat.save
        flash[:notice] = 'Cat was successfully created.'
        format.html { redirect_to(@cat) }
        format.xml  { render :xml => @cat, :status => :created, :location => @cat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cats/1
  # PUT /cats/1.xml
  def update
    @cat = Cat.find(params[:id])

    respond_to do |format|
      if @cat.update_attributes(params[:cat])
        flash[:notice] = 'Cat was successfully updated.'
        format.html { redirect_to(@cat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cats/1
  # DELETE /cats/1.xml
  def destroy
    @cat = Cat.find(params[:id])
    @cat.destroy

    respond_to do |format|
      format.html { redirect_to(cats_url) }
      format.xml  { head :ok }
    end
  end
end
