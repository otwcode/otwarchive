class TestiesController < ApplicationController

  auto_complete_for :testy, :first_name
  auto_complete_for :testy, :last_name
  auto_complete_for :testy, :address
  auto_complete_for :child1, :field1
  auto_complete_for :child1, :field2

  # GET /testies
  # GET /testies.xml
  def index
    @testies = Testy.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @testies }
    end
  end

  # GET /testies/1
  # GET /testies/1.xml
  def show
    @testy = Testy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @testy }
    end
  end

  # GET /testies/new
  # GET /testies/new.xml
  def new
    @testy = Testy.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @testy }
    end
  end

  # GET /testies/1/edit
  def edit
    @testy = Testy.find(params[:id])
  end

  # POST /testies
  # POST /testies.xml
  def create
    @testy = Testy.new(params[:testy])

    respond_to do |format|
      if @testy.save
        flash[:notice] = 'Testy was successfully created.'
        format.html { redirect_to(@testy) }
        format.xml  { render :xml => @testy, :status => :created, :location => @testy }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @testy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /testies/1
  # PUT /testies/1.xml
  def update
    @testy = Testy.find(params[:id])

    respond_to do |format|
      if @testy.update_attributes(params[:testy])
        flash[:notice] = 'Testy was successfully updated.'
        format.html { redirect_to(@testy) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @testy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /testies/1
  # DELETE /testies/1.xml
  def destroy
    @testy = Testy.find(params[:id])
    @testy.destroy

    respond_to do |format|
      format.html { redirect_to(testies_url) }
      format.xml  { head :ok }
    end
  end
end
