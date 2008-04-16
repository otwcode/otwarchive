class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    unless params[:user][:identity_url].blank?
      @user.identity_url = OpenIdAuthentication.normalize_url(@user.identity_url)
    end
    @user.pseuds << Pseud.new(:name => @user.login, :description => "Default pseud".t, :is_default => :true)

    respond_to do |format|
      if @user.save
        flash[:error] = 'Mailing currently is not working, so instead please use <a href=' + activate_path(@user.activation_code) + '>your activation url</a>.'
        format.html { render :partial => "confirmation", :layout => "application" }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def activate
    self.current_user = params[:id].blank? ? :false : User.find_by_activation_code(params[:id])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_to :action => :show, :id => current_user.id
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
  # Toggles is_translating on and off 
  def translating_toggle_image
    user = User.find(params[:id])
    # change the is_translating state
    user.toggle(:is_translating)
    if user.save
      redirect_to :back
    else
      render :text => "Couldn't change to translate mode"
    end
  end
  
  
end
