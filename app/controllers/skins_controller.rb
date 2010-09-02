class SkinsController < ApplicationController

  before_filter :users_only, :except => [:index, :show]
  before_filter :load_skin, :except => [:index, :new, :create]
  before_filter :check_ownership, :only => [:edit, :update, :destroy]
  before_filter :check_visibility, :only => [:show]
  before_filter :check_editability, :only => [:edit, :update, :destroy]

  def index
    if current_user && current_user.is_a?(User)
      @preference = current_user.preference
    end
    if params[:q] == 'mine'
      redirect_to new_session_path and return unless logged_in?
      @user = current_user
      @skins = @user.skins
      @title = t('my_skins', :default => 'My skins')
    else
      @skins = Skin.approved_skins
      @title = t('public_skins', :default => 'Public skins')
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
    @skin = Skin.new(params[:skin])
    @skin.author = current_user
    if @skin.save
      redirect_to @skin
      flash[:notice] = "Skin was created successfully"
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
      flash[:error] = "This skin can't be edited anymore!"
      redirect_to @skin and return 
    end
  end
  
  def destroy
    @skin = Skin.find_by_id(params[:id])
    begin
      @skin.destroy
    rescue
      flash[:error] = t('deletion_failed', :default => "We couldn't delete that right now, sorry! Please try again later.")
    end

    if current_user && current_user.is_a?(User) && current_user.preference.skin_id == @skin.id
      current_user.preference.update_attribute("skin_id", Skin.default.id)
    end
    redirect_to(skins_url(:q => "mine"))
  end
  
end
