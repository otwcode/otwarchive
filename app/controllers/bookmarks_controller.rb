class BookmarksController < ApplicationController 
  before_filter :load_bookmarkable, :only => [ :index, :new, :create ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
  before_filter :is_author, :only => [ :edit, :update, :destroy ]
  before_filter :check_permission_to_view ,:only => [:show]
  
  # Make sure hidden bookmarks aren't publically visible
  def check_permission_to_view
    @bookmark = Bookmark.find(params[:id])
    if @bookmark.hidden_by_admin?
      access_denied if !logged_in_as_admin? || !(logged_in? && current_user.is_author_of?(@bookmark))
    end
  end
  
  # Only the owner of the bookmark should be able to edit it
  def is_author
    @bookmark = Bookmark.find(params[:id])
    unless current_user.is_a?(User) && current_user.is_author_of?(@bookmark)
      flash[:error] = "Sorry, but you don't have permission to make edits.".t
      redirect_to(@bookmark)     
    end
  end
  
  # get the parent
  def load_bookmarkable
    if params[:work_id]
      @bookmarkable = Work.find(params[:work_id])
    end    
    if params[:external_work_id]
      @bookmarkable = ExternalWork.find(params[:external_work_id])
    end    
    if params[:user_id]
      @user = User.find_by_login(params[:user_id]) 
    end
  end  
  
  # GET    /:locale/bookmarks
  # GET    /:locale/users/:user_id/bookmarks 
  # GET    /:locale/works/:work_id/bookmarks 
  # GET    /:locale/external_works/:external_work_id/bookmarks
  def index
    if @user 
      @bookmarks = is_admin? ? @user.bookmarks.find(:all, :conditions => {:private => false}, :order => "created_at DESC").paginate(:page => params[:page]) : 
                               @user.bookmarks.visible(current_user, :order => "created_at DESC").paginate(:page => params[:page]) 
    elsif @bookmarkable.nil? 
      @bookmarks = is_admin? ? Bookmark.find(:all, :conditions => {:private => false}, :order => "created_at DESC").paginate(:page => params[:page]) : 
                               Bookmark.visible(current_user, :order => "created_at DESC").paginate(:page => params[:page]) 
    else 
      @bookmarks = is_admin? ? @bookmarkable.bookmarks.find(:all, :conditions => {:private => false}, :order => "created_at DESC").paginate(:page => params[:page]) :
                               @bookmarkable.bookmarks.visible(current_user, :order => "created_at DESC").paginate(:page => params[:page])
    end
    if @bookmarkable
      unless is_admin? || @bookmarkable.visible(current_user)
        render :file => "#{RAILS_ROOT}/public/403.html",  :status => 403 
      end
    end
  end

  # GET    /:locale/bookmark/:id
  # GET    /:locale/users/:user_id/bookmarks/:id
  # GET    /:locale/works/:work_id/bookmark/:id
  # GET    /:locale/external_works/:external_work_id/bookmark/:id
  def show
    @bookmark = Bookmark.find(params[:id])
    if @bookmark
      unless is_admin? || @bookmark.visible(current_user)
        render :file => "#{RAILS_ROOT}/public/403.html",  :status => 403 
      end
    end
  end

  # GET /bookmarks/new
  # GET /bookmarks/new.xml
  def new
    @bookmark = Bookmark.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /bookmarks/1/edit
  def edit
    @bookmark = Bookmark.find(params[:id])
    @bookmarkable = @bookmark.bookmarkable
    @tag_string = @bookmark.tag_string
  end

  # POST /bookmarks
  # POST /bookmarks.xml
  def create
    @bookmark = Bookmark.new(params[:bookmark])
    @bookmark.set_external(params[:fetched][:value].to_i) unless params[:fetched].blank? || params[:fetched][:value].blank?
    if @bookmark.save && @bookmark.tag_string=params[:tag_string]
      flash[:notice] = 'Bookmark was successfully created.'.t
      redirect_to(@bookmark) 
    else
      @bookmarkable = @bookmark.bookmarkable || ExternalWork.new
      render :action => "new" 
    end 
  end

  # PUT /bookmarks/1
  # PUT /bookmarks/1.xml
  def update
    @bookmark = Bookmark.find(params[:id])
    if @bookmark.update_attributes(params[:bookmark]) && @bookmark.tag_string=params[:tag_string]
      flash[:notice] = 'Bookmark was successfully updated.'.t
      redirect_to(@bookmark) 
    else
      render :action => "edit" 
    end
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.xml
  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    flash[:notice] = 'Bookmark was successfully deleted.'.t
    redirect_to user_bookmarks_path(current_user)
  end
end
