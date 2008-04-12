class PseudsController < ApplicationController
  
  before_filter :load_user  

  def load_user
    @user = User.find(params[:user_id])
  end
  

  # GET /pseuds
  # GET /pseuds.xml
  def index
    @pseuds = @user.pseuds.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pseuds }
    end
  end

  # GET /pseuds/1
  # GET /pseuds/1.xml
  def show
    @pseud = @user.pseuds.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pseud }
    end
  end

  # GET /pseuds/new
  # GET /pseuds/new.xml
  def new
    @pseud = @user.pseuds.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pseud }
    end
  end

  # GET /pseuds/1/edit
  def edit
    @pseud = @user.pseuds.find(params[:id])
  end

  # POST /pseuds
  # POST /pseuds.xml
  def create
    @pseud = @user.pseuds.build(params[:pseud])
    # if setting this one as default, unset the attribute of the current active pseud
    if params[:is_default]
      @user.active_pseud.is_default = false
    end
    respond_to do |format|
      if @pseud.save
        flash[:notice] = 'Pseud was successfully created.'
        format.html { redirect_to([@user, @pseud]) }
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
    @pseud = @user.pseuds.find(params[:id])
    # if setting this one as default, unset the attribute of the current active pseud
    if params[:is_default]
      @user.active_pseud.is_default = false
    end
    respond_to do |format|
      if @pseud.update_attributes(params[:pseud])
                
        flash[:notice] = 'Pseud was successfully updated.'
        format.html { redirect_to([@user, @pseud]) }
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
    @pseud = @user.pseuds.find(params[:id])
    if @pseud.is_default
      flash[:error] = "You cannot delete your default pseudonym, sorry!".t
    elsif @pseud.name == @user.login
      flash[:error] = "You cannot delete the pseud matching your username, sorry!".t
    else
      @pseud.destroy
      flash[:notice] = "Pseud destroyed".t
    end

    respond_to do |format|
      format.html { redirect_to(user_pseuds_url(@user)) }
      format.xml  { head :ok }
    end
  end
end
