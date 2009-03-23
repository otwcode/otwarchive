class BookmarksController < ApplicationController 
  before_filter :load_bookmarkable, :only => [ :index, :new, :create ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
  before_filter :is_author, :only => [ :edit, :update, :destroy ]
  
  # Only the owner of the bookmark should be able to edit it
  def is_author
    @bookmark = Bookmark.find(params[:id])
    unless current_user.is_a?(User) && current_user.is_author_of?(@bookmark)
      flash[:error] = t('errors.no_permission_to_edit', :default => "Sorry, but you don't have permission to make edits.")
     redirect_to(@bookmark)     
    end
  end
  
  # get the parent
  def load_bookmarkable
    if params[:work_id]
      @bookmarkable = Work.find(params[:work_id])
    elsif params[:external_work_id]
      @bookmarkable = ExternalWork.find(params[:external_work_id])
    end
  end  
  
  # GET    /:locale/bookmarks
  # GET    /:locale/users/:user_id/bookmarks 
  # GET    /:locale/works/:work_id/bookmarks 
  # GET    /:locale/external_works/:external_work_id/bookmarks
  def index
    if params[:user_id]
      @user = User.find_by_login(params[:user_id])
      owner = @user
    end
    if params[:pseud_id] && @user
      @pseud = @user.pseuds.find_by_name(params[:pseud_id])
      owner = @pseud
    elsif params[:tag_id]
      owner ||= Tag.find_by_name(params[:tag_id])
    else
      owner ||= @bookmarkable
    end
    search_by = owner ? "owner.bookmarks" : "Bookmark" 
    @bookmarks = is_admin? ? eval(search_by).find(:all, :conditions => {:private => false}, :order => "bookmarks.created_at DESC").paginate(:page => params[:page]) : 
                             eval(search_by).visible(:order => "bookmarks.created_at DESC").paginate(:page => params[:page])
    if @bookmarkable
      access_denied unless is_admin? || @bookmarkable.visible
    end
  end

  # GET    /:locale/bookmark/:id
  # GET    /:locale/users/:user_id/bookmarks/:id
  # GET    /:locale/works/:work_id/bookmark/:id
  # GET    /:locale/external_works/:external_work_id/bookmark/:id
  def show
    @bookmark = Bookmark.find(params[:id])
    unless @bookmark.visible || is_admin?
      if !current_user.is_a?(User)
        store_location 
        redirect_to new_session_path and return        
      elsif @bookmark.pseud.user != current_user
  	    flash[:error] = t('errors.bookmarks.not_visible', :default => 'This page is unavailable.')
       redirect_to user_path(current_user) and return
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
    begin
      if @bookmark.save && @bookmark.tag_string=params[:tag_string]
        flash[:notice] = t('notices.bookmarks.successfully_created', :default => 'Bookmark was successfully created.')
       redirect_to(@bookmark) 
      else
        raise
      end
    rescue
      @bookmarkable = @bookmark.bookmarkable || ExternalWork.new
      render :action => "new" 
    end 
  end

  # PUT /bookmarks/1
  # PUT /bookmarks/1.xml
  def update
    @bookmark = Bookmark.find(params[:id])
    begin
      if @bookmark.update_attributes(params[:bookmark]) && @bookmark.tag_string=params[:tag_string]
        flash[:notice] = t('notices.bookmarks.successfully_updated', :default => 'Bookmark was successfully updated.')
       redirect_to(@bookmark) 
      else
        raise
      end
    rescue
      @bookmarkable = @bookmark.bookmarkable || ExternalWork.new
      render :action => :edit
    end
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.xml
  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    flash[:notice] = t('notices.bookmarks.successfully_deleted', :default => 'Bookmark was successfully deleted.')
   redirect_to user_bookmarks_path(current_user)
  end
end
