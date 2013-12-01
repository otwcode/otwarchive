class SkinsController < ApplicationController

  before_filter :users_only, :only => [:new, :create, :destroy]
  before_filter :load_skin, :except => [:index, :new, :create, :unset]
  before_filter :check_title, :only => [:create, :update]
  before_filter :check_ownership_or_admin, :only => [:edit, :update]
  before_filter :check_ownership, :only => [:destroy]
  before_filter :check_visibility, :only => [:show]
  before_filter :check_editability, :only => [:edit, :update, :destroy]

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
  
  def check_title
    if params[:skin][:title].match(/archive/i)
      flash[:error] = ts("You can't use the word 'archive' in your skin title, sorry! (We have to reserve it for official skins.)")
      render (@skin ? :edit : :new) and return
    end
  end
  
  # if we've been asked to load the archive parents, we do so and add them to params
  def load_archive_parents
    if params[:add_site_parents]
      params[:skin][:skin_parents_attributes] ||= HashWithIndifferentAccess.new
      archive_parents = Skin.get_current_site_skin.get_all_parents
      skin_parent_titles = params[:skin][:skin_parents_attributes].values.map {|v| v[:parent_skin_title]}
      skin_parents = skin_parent_titles.empty? ? [] : Skin.where(:title => skin_parent_titles).value_of(:id) 
      skin_parents += @skin.get_all_parents.collect(&:id) if @skin
      if !(skin_parents.uniq & archive_parents.collect(&:id)).empty?
        flash[:error] = ts("You already have some of the archive components as parents, so we couldn't load the others. Please remove the existing components first if you really want to do this!")
        return true
      end
      last_position = params[:skin][:skin_parents_attributes].keys.map{|k| k.to_i}.max rescue 0      
      last_position ||= 0
      archive_parents.each do |parent_skin|                
        last_position += 1
        new_skin_parent_hash = HashWithIndifferentAccess.new({:position => last_position, :parent_skin_id => parent_skin.id})
        params[:skin][:skin_parents_attributes].merge!({last_position => new_skin_parent_hash})
      end
      return true
    end
    return false
  end
  
  #### ACTIONS
  
  def index
    is_work_skin = params[:skin_type] && params[:skin_type] == "WorkSkin"
    if current_user && current_user.is_a?(User)
      @preference = current_user.preference
    end
    if params[:user_id] && @user = User.find_by_login(params[:user_id])
      redirect_to new_user_session_path and return unless logged_in?
      if (@user != current_user)
        flash[:error] = "You can only browse your own skins and approved public skins." 
        redirect_to skins_path and return
      end
      if is_work_skin
        @skins = @user.work_skins.sort_by_recent
        @title = ts('My Work Skins')
      else
        @skins = @user.skins.site_skins.sort_by_recent
        @title = ts('My Site Skins')
      end
    else
      if is_work_skin
        @skins = WorkSkin.approved_skins.sort_by_recent_featured
        @title = ts('Public Work Skins')
      else
        if logged_in? 
          @skins = Skin.approved_skins.usable.site_skins.sort_by_recent_featured
        else
          @skins = Skin.approved_skins.usable.site_skins.cached.sort_by_recent_featured
        end
        @title = ts('Public Skins')
      end
    end
  end

  def show
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
    loaded = load_archive_parents unless params[:skin_type] && params[:skin_type] == 'WorkSkin'
    @skin = params[:skin_type] ? params[:skin_type].constantize.new(params[:skin]) : Skin.new(params[:skin])
    @skin.author = current_user
    if @skin.save
      flash[:notice] =  ts("Skin was successfully created.")
      if loaded
        flash[:notice] += ts(" We've added all the archive skin components as parents. You probably want to remove some of them now!")
        redirect_to edit_skin_path(@skin)
      else
        redirect_to @skin
      end
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
    loaded = load_archive_parents
    if @skin.update_attributes(params[:skin])      
      @skin.cache! if @skin.cached?
      flash[:notice] = ts("Skin was successfully updated.")
      if loaded
        if flash[:error].present?
          flash[:notice] = ts("Any other edits were saved.")
        else
          flash[:notice] += ts(" We've added all the archive skin components as parents. You probably want to remove some of them now!")
        end
        redirect_to edit_skin_path(@skin)
      else
        redirect_to @skin
      end
    else
      render :action => "edit"
    end
  end
  
  def preview
    flash[:notice] = []
    flash[:notice] << ts("You are previewing the skin %{title}. This is a randomly chosen page.", :title => @skin.title)
    flash[:notice] << ts("Go back or click any link to remove the skin.")
    flash[:notice] << ts("Tip: You can preview any archive page you want by tacking on '?site_skin=[skin_id]' like you can see in the url above.")
    flash[:notice] << "<a href='#{skin_path(@skin)}' class='action' role='button'>".html_safe + ts("Return To Skin To Use") + "</a>".html_safe
    tag = FilterCount.where("public_works_count BETWEEN 10 AND 20").order("RAND()").first.filter
    redirect_to tag_works_path(tag, :site_skin => @skin.id)
  end

  def set
    if @skin.cached?
      flash[:notice] = ts("The skin %{title} has been set. This will last for your current session.", :title => @skin.title)
      session[:site_skin] = @skin.id
    else
      flash[:error] = ts("Sorry, but only certain skins can be used this way (for performance reasons). Please drop a support request if you'd like %{title} to be added!", :title => @skin.title)
    end
    redirect_back_or_default @skin
  end
  
  def unset
    session[:site_skin] = nil
    if logged_in? && current_user.preference
      current_user.preference.skin = Skin.default
      current_user.preference.save
    end    
    flash[:notice] = ts("You are now using the default Archive skin again!")
    redirect_back_or_default "/"
  end

  def destroy
    @skin = Skin.find_by_id(params[:id])
    begin
      @skin.destroy
      flash[:notice] = ts("The skin was deleted.")
    rescue
      flash[:error] = ts("We couldn't delete that right now, sorry! Please try again later.")
    end

    if current_user && current_user.is_a?(User) && current_user.preference.skin_id == @skin.id
      current_user.preference.update_attribute("skin_id", Skin.default.id)
    end
    redirect_to user_skins_path(current_user) rescue redirect_to skins_path
  end
  
end
