class BookmarksController < ApplicationController 
  before_filter :load_bookmarkable, :only => [ :index, :new, :create ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
  before_filter :load_bookmark, :only => [ :show, :edit, :update, :destroy ] 
  before_filter :check_visibility, :only => [ :show ]
  before_filter :check_ownership, :only => [ :edit, :update, :destroy ]
  
  # get the parent
  def load_bookmarkable
    if params[:work_id]
      @bookmarkable = Work.find(params[:work_id])
    elsif params[:external_work_id]
      @bookmarkable = ExternalWork.find(params[:external_work_id])
    end
  end  

  def load_bookmark
    @bookmark = Bookmark.find(params[:id])
    @check_ownership_of = @bookmark
    @check_visibility_of = @bookmark
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
      @author = @pseud = @user.pseuds.find_by_name(params[:pseud_id]) 
      # @author is needed in the sidebar and I'm too lazy to redo the whole thing
      owner = @pseud
    elsif params[:tag_id]
      owner ||= Tag.find_by_name(params[:tag_id])
    else
      owner ||= @bookmarkable
    end
    # Do not want to aggregate bookmarks on these pages
    if params[:pseud_id] || params[:user_id] || params[:work_id] || params[:external_work_id] 
      search_by = owner ? "owner.bookmarks" : "Bookmark"
      @bookmarks = eval(search_by).visible(:order => "bookmarks.created_at DESC").paginate(:page => params[:page])
    else # Aggregate on main bookmarks page, tag page
      if params[:tag_id] 
        @most_recent_bookmarks = false
        # Want to get not only bookmarks with tag, but also bookmarks on works with tag
        @works_with_tag = owner.works.visible.collect(&:id)
        @works_with_tagged_bookmarks = owner.bookmarks.visible(:conditions => {:bookmarkable_type => 'Work'}).collect(&:bookmarkable_id).uniq
        work_ids = @works_with_tag | @works_with_tagged_bookmarks
        external_work_ids = owner.bookmarks.visible(:conditions => {:bookmarkable_type => 'ExternalWork'}).collect(&:bookmarkable_id).uniq
      else # Show only bookmarks from past month on main page
        @most_recent_bookmarks = true
        work_ids = Bookmark.recent.visible(:conditions => {:bookmarkable_type => 'Work'}).collect(&:bookmarkable_id).uniq
        external_work_ids = Bookmark.recent.visible(:conditions => {:bookmarkable_type => 'ExternalWork'}).collect(&:bookmarkable_id).uniq         
      end
      # Still looking for a neater way to do this
      @bookmarks = []
      bookmarkable_types = ["Work", "ExternalWork"]
      bookmarkable_types.each do |bt|
        bt_ids = bt.foreign_key.pluralize
        eval(bt_ids).each do |bt_id|
          @bookmarks << eval(bt).find(bt_id).bookmarks.visible.last unless eval(bt).find(bt_id).bookmarks.visible.blank?
        end
      end
      @bookmarks = @bookmarks.sort_by(&:created_at).reverse.paginate(:page => params[:page])
    end
    if @bookmarkable
      access_denied unless is_admin? || @bookmarkable.class == ExternalWork || @bookmarkable.visible
    end
  end
  
  # GET    /:locale/bookmark/:id
  # GET    /:locale/users/:user_id/bookmarks/:id
  # GET    /:locale/works/:work_id/bookmark/:id
  # GET    /:locale/external_works/:external_work_id/bookmark/:id
  def show
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
        flash[:notice] = t('successfully_created', :default => 'Bookmark was successfully created.')
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
    begin
      if @bookmark.update_attributes(params[:bookmark]) && @bookmark.tag_string=params[:tag_string]
        flash[:notice] = t('successfully_updated', :default => 'Bookmark was successfully updated.')
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
    @bookmark.destroy
    flash[:notice] = t('successfully_deleted', :default => 'Bookmark was successfully deleted.')
   redirect_to user_bookmarks_path(current_user)
  end
end
