class BookmarksController < ApplicationController 
  before_filter :load_bookmarkable, :only => [ :index, :new, :create ]
  
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
    @bookmarks = @user ? @user.bookmarks.visible(current_user).paginate(:page => params[:page]) : @bookmarkable.nil? ? Bookmark.visible(current_user).paginate(:page => params[:page]) : @bookmarkable.bookmarks.visible(current_user).paginate(:page => params[:page])
    if @bookmarkable
      unless @bookmarkable.visible(current_user)
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
      unless @bookmark.visible(current_user)
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
      flash[:notice] = 'Bookmark was successfully created.'
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
      flash[:notice] = 'Bookmark was successfully updated.'
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
    flash[:notice] = 'Bookmark was successfully deleted.'
    redirect_to user_bookmarks_path(current_user)
  end
end
