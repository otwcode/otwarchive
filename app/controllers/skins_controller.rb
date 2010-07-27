class SkinsController < ApplicationController

  before_filter :users_only, :except => [:index, :show]
  before_filter :load_skin, :except => [:index, :new, :create]
  before_filter :check_ownership, :only => [:edit, :update, :destroy]
  before_filter :check_visibility, :only => [:show]

  def index
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
    else
      render :action => "new"
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

end
