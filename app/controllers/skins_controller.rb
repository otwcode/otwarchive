class SkinsController < ApplicationController

  before_filter :users_only, :except => [:index, :show]

  def index
    @current_user = current_user
    if params[:q] == 'mine'
      @skins = current_user.skins
      @title = t('my_skins', :default => 'My skins')
    else
      @skins = Skin.public_skins
      @title = t('public_skins', :default => 'Public skins')
    end
  end

  def show
    @skin = Skin.find(params[:id])
    @current_user = current_user
  end

  def new
    @skin = Skin.new
    @current_user = current_user
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
    @skin = Skin.find(params[:id])
    @current_user = current_user
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Skin not found"
    redirect_to skins_url
  end

  def update
    @skin = Skin.find(params[:id])
    @current_user = current_user
    if @skin.update_attributes(params[:skin])
      flash[:notice] = "Skin updated."
      redirect_to @skin
    else
      render :action => "edit"
    end
  end

  
end
