class PseudsController < ApplicationController
  
  before_filter :load_user
  
  def load_user
    @user = User.find(params[:user_id])
  end
  
  
  # GET /pseuds
  # GET /pseuds.xml
  def index
    @pseuds = @user.pseuds.find(:all)
  end
  
  # GET /pseuds/1
  # GET /pseuds/1.xml
  def show
    @pseud = @user.pseuds.find(params[:id])
  end
  
  # GET /pseuds/new
  # GET /pseuds/new.xml
  def new
    @pseud = @user.pseuds.build
  end
  
  # GET /pseuds/1/edit
  def edit
    @pseud = @user.pseuds.find(params[:id])
  end
  
  # POST /pseuds
  # POST /pseuds.xml
  def create
    @pseud = @user.pseuds.build(params[:pseud])
    default = @user.default_pseud
    if @pseud.save
      flash[:notice] = 'Pseud was successfully created.'
      if @pseud.is_default
        # if setting this one as default, unset the attribute of the current default pseud
        default.update_attribute(:is_default, false)
      end
      redirect_to([@user, @pseud])
    else
      render :action => "new"
    end
  end
  
  # PUT /pseuds/1
  # PUT /pseuds/1.xml
  def update
    @pseud = @user.pseuds.find(params[:id])
    default = @user.default_pseud
    if @pseud.update_attributes(params[:pseud])
      # if setting this one as default, unset the attribute of the current default pseud
      if @pseud.is_default and not(default == @pseud)
        # if setting this one as default, unset the attribute of the current active pseud
        default.update_attribute(:is_default, false)
      end   
      flash[:notice] = 'Pseud was successfully updated.'
      redirect_to([@user, @pseud]) 
    else
      render :action => "edit"
    end
  end
  
  # DELETE /pseuds/1
  # DELETE /pseuds/1.xml
  def destroy
    @pseud = @user.pseuds.find(params[:id])
    @pseud.move_creations_to_default
    if @pseud.is_default
      flash[:error] = "You cannot delete your default pseudonym, sorry!".t
    elsif @pseud.name == @user.login
      flash[:error] = "You cannot delete the pseud matching your username, sorry!".t
    else
      @pseud.destroy
      flash[:notice] = "Pseud destroyed".t
    end
    
    redirect_to(user_pseuds_url(@user)) 
  end
end
