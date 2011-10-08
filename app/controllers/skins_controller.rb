class SkinsController < ApplicationController

  before_filter :users_only, :only => [:new, :create, :destroy]
  before_filter :load_skin, :except => [:index, :new, :create]
  before_filter :check_ownership_or_admin, :only => [:edit, :update]
  before_filter :check_ownership, :only => [:destroy]
  before_filter :check_visibility, :only => [:show]
  before_filter :check_editability, :only => [:edit, :update, :destroy]

  cache_sweeper :skin_sweeper

  def index
    if current_user && current_user.is_a?(User)
      @preference = current_user.preference
    end
    if params[:user_id] && @user = User.find_by_login(params[:user_id])
      redirect_to new_user_session_path and return unless logged_in?
      if (@user != current_user)
        flash[:error] = "You can only browse your own skins and approved public skins." 
        redirect_to skins_path and return
      end
      if params[:work_skins]
        @skins = @user.work_skins.sort_by_recent
        @title = ts('My Work Skins')
      else
        @skins = @user.skins.site_skins.sort_by_recent
        @title = ts('My Site Skins')
      end
    else
      if params[:work_skins]
        @skins = WorkSkin.approved_skins.sort_by_recent
        @title = ts('Public Work Skins')
      else
        @skins = Skin.approved_skins.usable.site_skins.sort_by_recent
        @title = ts('Public Skins')
      end
    end
  end

  def show
    @skin = Skin.find(params[:id])

  end

  def new
    @skin = Skin.new
    if params[:wizard]
      render :new_wizard and return
    else
      render :new and return
    end
  end

  def create
    if params[:skin][:title].match(/archive/i)
      flash[:error] = ts("You can't use the word 'archive' in your skin title, sorry! (We have to reserve it for official skins.)")
      render :new and return
    end
    @skin = params[:skin_type] ? params[:skin_type].constantize.new(params[:skin]) : Skin.new(params[:skin])
    @skin.author = current_user
    if @skin.save
      redirect_to @skin
      flash[:notice] = "Skin was successfully created"
    else
      if params[:wizard]
        render :new_wizard
      else
        render :new
      end
    end
  end

  def edit
  end

  def update
    if params[:skin][:title].match("/^Archive/")
      flash[:error] = ts("You can't name your skin starting with 'Archive', sorry!")
      render :edit and return
    end
    if @skin.update_attributes(params[:skin])
      flash[:notice] = "Skin updated."
      redirect_to @skin
    else
      render :action => "edit"
    end
  end

  def load_skin
    @skin = Skin.find_by_id(params[:id])
    unless @skin
      flash[:error] = "Skin not found"
      redirect_to skins_url and return
    end
    @check_ownership_of = @skin
    @check_visibility_of = @skin
  end

  def check_editability
    unless @skin.editable?
      flash[:error] = ts("Sorry, you don't have permission to edit this skin")
      redirect_to @skin and return 
    end
  end
  
  def destroy
    @skin = Skin.find_by_id(params[:id])
    begin
      @skin.destroy
    rescue
      flash[:error] = ts("We couldn't delete that right now, sorry! Please try again later.")
    end

    if current_user && current_user.is_a?(User) && current_user.preference.skin_id == @skin.id
      current_user.preference.update_attribute("skin_id", Skin.default.id)
    end
    redirect_to(skins_url(:q => "mine"))
  end
  
end
