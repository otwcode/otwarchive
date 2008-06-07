class BookmarksController < ApplicationController 
  before_filter :load_bookmarkable, :only => [ :index, :new, :create ]
  
  # Get the parent of the desired comment(s) 
  # Just covering all the bases here for now
  def load_bookmarkable
    if params[:work_id]
      @bookmarkable = Work.find(params[:work_id])
    end    
  end  
  
  # GET /bookmarks
  # GET /bookmarks.xml
  def index
    @bookmarks = @bookmarkable.nil? ? Bookmark.find(:all) : 
      Bookmark.find(:all, :conditions => {:bookmarkable_id => @bookmarkable.id, :bookmarkable_type => @bookmarkable.class.to_s})
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.xml
  def show
    @bookmark = Bookmark.find(params[:id])
  end

  # GET /bookmarks/new
  # GET /bookmarks/new.xml
  def new
    @bookmark = Bookmark.new
  end

  # GET /bookmarks/1/edit
  def edit
    @bookmark = Bookmark.find(params[:id])
    @bookmarkable = @bookmark.bookmarkable
  end

  # POST /bookmarks
  # POST /bookmarks.xml
  def create
    @bookmark = Bookmark.new(params[:bookmark])
    if @bookmark.save
      flash[:notice] = 'Bookmark was successfully created.'
      redirect_to(@bookmark) 
    else
      render :action => "new" 
    end 
  end

  # PUT /bookmarks/1
  # PUT /bookmarks/1.xml
  def update
    @bookmark = Bookmark.find(params[:id])
    if @bookmark.update_attributes(params[:bookmark])
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
    redirect_to(bookmarks_url)
  end
end
