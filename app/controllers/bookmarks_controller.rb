class BookmarksController < ApplicationController 
  before_filter :load_collection
  before_filter :load_bookmarkable, :only => [ :index, :new, :create, :fetch_recent ]
  before_filter :users_only, :only => [:new, :create, :edit, :update]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
  before_filter :load_bookmark, :only => [ :show, :edit, :update, :destroy, :fetch_recent ] 
  before_filter :check_visibility, :only => [ :show ]
  before_filter :check_ownership, :only => [ :edit, :update, :destroy ]
  
  # get the parent
  def load_bookmarkable
    if params[:work_id]
      @bookmarkable = Work.find(params[:work_id])
    elsif params[:external_work_id]
      @bookmarkable = ExternalWork.find(params[:external_work_id])
    elsif params[:series_id]
      @bookmarkable = Series.find(params[:series_id])
    end
  end  

  def load_bookmark
    @bookmark = Bookmark.find(params[:id])
    @check_ownership_of = @bookmark
    @check_visibility_of = @bookmark
  end

  
  # aggregates bookmarks for the same bookmarkable
  # note, these do not show private bookmarks
  # GET    /bookmarks
  # GET    /tags/:tag_id/bookmarks
  # non aggregates - show all bookmarks, even duplicates and private
  # GET    /collections/:collection_id/bookmarks
  # GET    /users/:user_id/pseuds/:pseud_id/bookmarks
  # GET    /users/:user_id/bookmarks
  # GET    /works/:work_id/bookmarks
  # GET    /external_works/:external_work_id/bookmarks
  # GET    /series/:series/bookmarks
  def index
    if @bookmarkable
      access_denied unless is_admin? || @bookmarkable.visible
    end
    if params[:user_id]
      # @user is needed in the sidebar
      owner = @user = User.find_by_login(params[:user_id])
      if params[:pseud_id] && @user
        # @author is needed in the sidebar
        owner = @author = @user.pseuds.find_by_name(params[:pseud_id])
      end
    elsif params[:tag_id]
      owner ||= Tag.find_by_name(params[:tag_id])
    elsif @collection
      owner ||= @collection
    else
      owner ||= @bookmarkable
    end
    if params[:user_id] || params[:work_id] || params[:external_work_id] || params[:series_id] || params[:collection_id]
      unless owner
        # we have to manually trigger a 404 when we're using find_by_name
        # otherwise the user gets a 500 error
        raise ActiveRecord::RecordNotFound
      end
      # Do not aggregate bookmarks on these pages
      if params[:recs_only]
        @bookmarks = owner.bookmarks.recs.visible
      else
        @bookmarks = owner.bookmarks.visible
      end
    else 
      # Aggregate on main bookmarks page and tags bookmarks page
      if params[:tag_id]  # tag page
        unless owner
          raise ActiveRecord::RecordNotFound, "Couldn't find tag named '#{params[:tag_id]}'"
        end        
        bookmarks_on_synonyms = []
        if params[:recs_only]
          bookmarks_primary = owner.bookmarks.recs.visible
          owner.synonyms.each do |synonym|
            bookmarks_on_synonyms << synonym.bookmarks.recs.visible 
          end rescue NoMethodError
          bookmarks_indirect = owner.indirect_bookmarks(true)
        else
          bookmarks_primary = owner.bookmarks.visible
          owner.synonyms.each do |synonym|
            bookmarks_on_synonyms << synonym.bookmarks.visible 
          end rescue NoMethodError
          bookmarks_indirect = owner.indirect_bookmarks
        end
        bookmarks_grouped = (bookmarks_primary + bookmarks_on_synonyms + bookmarks_indirect).flatten.compact.group_by(&:bookmarkable)
      else # main page
        @most_recent_bookmarks = true
        if params[:recs_only]
          bookmarks_grouped = Bookmark.recs.recent.public.reject{|b| b.bookmarkable && !b.bookmarkable.visible?(current_user)}.group_by(&:bookmarkable)
        else
          bookmarks_grouped = Bookmark.recent.public.reject{|b| b.bookmarkable && !b.bookmarkable.visible?(current_user)}.group_by(&:bookmarkable)
        end
      end
      @bookmarks = []
      bookmarks_grouped.values.each do |bookmarks|
        if bookmarks.size == 1 || bookmarks.map(&:bookmarkable_type).uniq.size == 1
           @bookmarks << bookmarks.first
        else
           bookmarkables = bookmarks.map(&:bookmarkable).uniq.compact
           bookmarkables.each do |bookmarkable|
             @bookmarks << bookmarkable.bookmarks.public.first
           end
        end
      end
      @bookmarks = @bookmarks.sort_by{|b| - b.id}
    end
    @bookmarks = @bookmarks.compact.paginate(:page => params[:page])
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
    unless params[:fetched].blank? || params[:fetched][:value].blank?
      fandom_string = params[:bookmark][:external][:fandom_string].to_s
      rating_string = params[:bookmark][:external][:rating_string].to_s
      category_string = params[:bookmark][:external][:category_string].to_s
      pairing_string = params[:bookmark][:external][:pairing_string].to_s
      character_string = params[:bookmark][:external][:character_string].to_s
    @bookmark.set_external(params[:fetched][:value].to_i, fandom_string, rating_string, category_string, pairing_string, character_string)
    end
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

  # Used on index page to show 4 most recent bookmarks (after bookmark being currently viewed) via RJS
  # Only main bookmarks page or tag bookmarks page
  # No direct non-JS fallback, as we have the 'view all bookmarks' link which serves the same function
  def fetch_recent
    if request.xml_http_request?
      @bookmarkable = @bookmark.bookmarkable
      @recent_bookmarks = @bookmarkable.bookmarks.visible(:order => "created_at DESC", :limit => 4, :offset => 1)
        respond_to do |format|
        format.js
      end
    else # redirect if not AJAX, e.g. if redirected from login form
      if params[:tag_id]
        redirect_to :action => 'index', :tag_id => params[:tag_id]
      else
        redirect_to bookmarks_path
      end
    end
  end

end
