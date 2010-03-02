class PseudsController < ApplicationController

  before_filter :load_user
  before_filter :check_ownership, :only => [:create, :edit, :destroy, :new, :update]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]

  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
  end

  # GET /pseuds
  # GET /pseuds.xml
  def index
    if @user
      @pseuds = @user.pseuds.find(:all)
    else
      redirect_to people_path
    end
  end

  # GET /pseuds/1
  # GET /pseuds/1.xml
  def show
    if @user
      @author = @user.pseuds.find_by_name(params[:id])
      unless @author
        flash[:error] = t('pseud_not_found', :default => "Sorry, could not find this pseud.")
        redirect_to :action => :index and return
      end
      @works = Work.written_by_conditions([@author]).visible.ordered_by_date_desc.limited(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
      if current_user == :false
        @series = Series.visible_to_public.exclude_anonymous.for_pseuds([@author]).find(:all, :limit => ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD).paginate(:page => params[:page])
      else
        @series = Series.visible_logged_in.exclude_anonymous.for_pseuds([@author]).find(:all, :limit => ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD).paginate(:page => params[:page])
      end
      visible_bookmarks = @author.bookmarks.visible(:order => 'bookmarks.created_at DESC')
      # Having the number of items as a limit was finding the limited number of items, then visible ones within them
      @bookmarks = visible_bookmarks[0...ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD]     
    else
      @pseuds = Pseud.find_all_by_name(params[:id])
      if @pseuds.size == 0
        flash[:error] = t('pseud_not_found', :default => "Sorry, could not find this pseud.")
        redirect_to people_path and return
      elsif @pseuds.size == 1
        redirect_to [@pseuds[0].user, @pseuds[0]] and return
      else
        flash[:notice] = t('ambiguous_pseud', :default => "There's more than one user with this pseud.")
        redirect_to people_path and return
        # TODO: present the user with a drop-down with all authors who have that pseud
      end
    end
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
    @pseud = @user.pseuds.find_by_name(params[:id])
  end

  # POST /pseuds
  # POST /pseuds.xml
  def create
    @pseud = Pseud.new(params[:pseud])
    unless @user.has_pseud?(@pseud.name)
      @user.pseuds << @pseud
      default = @user.default_pseud
      if @pseud.save
        flash[:notice] = t('successfully_created', :default => 'Pseud was successfully created.')
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
      flash[:error] = t('duplicate_pseud', :default => 'You already have a pseud with that name.')
     @pseud.name = '' if @user.default_pseud.name == @pseud.name
      render :action => "new"
    end
  end

  # PUT /pseuds/1
  # PUT /pseuds/1.xml
  def update
    @pseud = @user.pseuds.find_by_name(params[:id])
    default = @user.default_pseud
    if @pseud.update_attributes(params[:pseud])
      # if setting this one as default, unset the attribute of the current default pseud
      if @pseud.is_default and not(default == @pseud)
        # if setting this one as default, unset the attribute of the current active pseud
        default.update_attribute(:is_default, false)
      end
      flash[:notice] = t('successfully_updated', :default => 'Pseud was successfully updated.')
     redirect_to([@user, @pseud])
    else
      render :action => "edit"
    end
  end

  # DELETE /pseuds/1
  # DELETE /pseuds/1.xml
  def destroy
    @hide_dashboard = true
    @pseud = @user.pseuds.find_by_name(params[:id])
    if @pseud.is_default
      flash[:error] = t('delete_default', :default => "You cannot delete your default pseudonym, sorry!")
   elsif @pseud.name == @user.login
      flash[:error] = t('delete_user_name', :default => "You cannot delete the pseud matching your user name, sorry!")
   elsif params[:bookmarks_action] == 'transfer_bookmarks'
     @pseud.change_bookmarks_ownership
     @pseud.replace_me_with_default
     flash[:notice] = t('successfully_deleted', :default => "The pseud was successfully deleted.")
   elsif params[:bookmarks_action] == 'delete_bookmarks' || @pseud.bookmarks.empty?
     @pseud.replace_me_with_default
     flash[:notice] = t('successfully_deleted', :default => "The pseud was successfully deleted.")
   else
      render :partial => 'delete_preview', :layout => 'application' and return  
   end

    redirect_to(user_pseuds_url(@user))
  end
end
