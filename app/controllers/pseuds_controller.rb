class PseudsController < ApplicationController
  
  before_filter :load_user
  before_filter :is_user_true, :only => [:create, :edit, :destroy, :new, :update]

  def load_user
    @user = User.find_by_login(params[:user_id])
  end

  # returns true if the current user is the user who owns the pseud(s)  
  def is_user?
    @user == current_user
  end

  #displays error if someone tries to modify another user's pseuds
  def is_user_true
    is_user? || [redirect_to(:action => "index"), flash[:error] = 'Sorry, but you don\'t have permission to make edits.' ]
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
  
  # For use with work/chapter forms
  def choose_coauthors
    byline = params[:search].strip
    if byline.include? "["
      split = byline.split('[', 2)
      pseud_name = split.first.strip
      user_login = split.last.chop
      conditions = [ 'LOWER(users.login) LIKE ? AND LOWER(name) LIKE ?','%' + user_login + '%',  '%' + pseud_name + '%' ]
    else
      conditions = [ 'LOWER(name) LIKE ?', '%' + byline + '%' ]
    end
    @pseuds = Pseud.find(:all, :include => :user, :conditions => conditions, :limit => 10)
    respond_to do |format|
        format.html
        format.js
      end
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
    @pseud = Pseud.new(params[:pseud])
    unless @user.has_pseud?(@pseud.name)
      @user.pseuds << @pseud
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
    else
      # user tried to add pseud he already has
      flash[:error] = 'You already have a pseud with that name.'
      @pseud.name = '' if @user.default_pseud.name == @pseud.name
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
    if @pseud.is_default
      flash[:error] = "You cannot delete your default pseudonym, sorry!".t
    elsif @pseud.name == @user.login
      flash[:error] = "You cannot delete the pseud matching your ".t + "user name".t + ", sorry!".t
    else
      @pseud.move_creations_to_default && @pseud.destroy
      flash[:notice] = "Pseud destroyed".t
    end
    
    redirect_to(user_pseuds_url(@user)) 
  end
end
