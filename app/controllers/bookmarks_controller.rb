class BookmarksController < ApplicationController 
  before_filter :load_collection
  before_filter :load_bookmarkable, :only => [ :index, :new, :create, :fetch_recent, :hide_recent ]
  before_filter :users_only, :only => [:new, :create, :edit, :update]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
  before_filter :load_bookmark, :only => [ :show, :edit, :update, :destroy, :fetch_recent, :hide_recent ] 
  before_filter :check_visibility, :only => [ :show ]
  before_filter :check_ownership, :only => [ :edit, :update, :destroy ]
  
  # get the parent
  def load_bookmarkable
    if params[:work_id]
      @bookmarkable = Work.find(params[:work_id])
    elsif params[:chapter_id]
      @bookmarkable = Chapter.find(params[:chapter_id]).try(:work)
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

  def search
    @query = {}
    if params[:query]
      @query = Query.standardize(params[:query])
      begin
        page = params[:page] || 1
        errors, @bookmarks = Query.search_with_sphinx(Bookmark, @query, page)
        flash.now[:error] = errors.join(" ") unless errors.blank?
      rescue Riddle::ConnectionError
        flash.now[:error] = ts("The search engine seems to be down at the moment, sorry!")
      end
    end
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
  # TODO needs a complete overhaul. using reject is a performance killer
  def index
    if @bookmarkable
      access_denied unless is_admin? || @bookmarkable.visible
    end
    if params[:user_id]
      # @user is needed in the sidebar
      owner = @user = User.find_by_login(params[:user_id])
      @page_subtitle = ts("by ") + @user.login
      if params[:pseud_id] && @user
        # @author is needed in the sidebar
        owner = @author = @user.pseuds.find_by_name(params[:pseud_id])
        @page_subtitle = ts("by ") + @author.byline
      end
    elsif params[:tag_id]
      owner ||= Tag.find_by_name(params[:tag_id])
      @page_subtitle = owner.name
    elsif @collection
      @page_subtitle = @collection.title
      owner ||= @collection # insufficient to filter out unapproved bookmarks, see below
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
      if params[:collection_id] && @collection
        @bookmarks = Bookmark.in_collection(@collection)
      else
        @bookmarks= owner.bookmarks
      end

      if params[:recs_only]
        @bookmarks = @bookmarks.recs
      end

      if @user && @user == current_user
        # can see all own bookmarks
      elsif logged_in_as_admin?
        @bookmarks = @bookmarks.visible_to_admin
      elsif logged_in?
        @bookmarks = @bookmarks.visible_to_registered_user
      else
        @bookmarks = @bookmarks.visible_to_all
      end
    else 
      # Aggregate on main bookmarks page and tags bookmarks page
      if params[:tag_id]  # tag page
        unless owner
          raise ActiveRecord::RecordNotFound, "Couldn't find tag named '#{params[:tag_id]}'"
        end        
        bookmarks_on_synonyms = []
        if params[:recs_only]
          bookmarks_primary = owner.bookmarks.recs
          owner.synonyms.each do |synonym|
            bookmarks_on_synonyms << synonym.bookmarks.recs
            bookmarks_on_synonyms << synonym.indirect_bookmarks(true)
          end rescue NoMethodError
          bookmarks_indirect = owner.indirect_bookmarks(true)
        else
          bookmarks_primary = owner.bookmarks
          owner.synonyms.each do |synonym|
            bookmarks_on_synonyms << synonym.bookmarks
            bookmarks_on_synonyms << synonym.indirect_bookmarks
          end rescue NoMethodError
          bookmarks_indirect = owner.indirect_bookmarks
        end
        all_bookmarks = (bookmarks_primary + bookmarks_on_synonyms + bookmarks_indirect).flatten.compact
        bookmarks_grouped = all_bookmarks.reject{|b| !b.visible?(current_user) || (b.bookmarkable && !b.bookmarkable.visible?(current_user))}.group_by(&:bookmarkable)
      else # main page
        @most_recent_bookmarks = true
        if params[:recs_only]
          bookmarks_grouped = Bookmark.recs.recent.visible_to_user(current_user).group_by(&:bookmarkable)
          @page_subtitle = ts("recs")
        else
          bookmarks_grouped = Bookmark.recent.visible_to_user(current_user).group_by(&:bookmarkable)
        end
      end
      @bookmarks = []
      bookmarks_grouped.values.each do |bookmarks|
        if bookmarks.size == 1 || bookmarks.map(&:bookmarkable_type).uniq.size == 1
           @bookmarks << bookmarks.first
        else
           bookmarkables = bookmarks.map(&:bookmarkable).uniq.compact
           bookmarkables.each do |bookmarkable|
             @bookmarks << bookmarkable.bookmarks.is_public.first
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
      format.js { 
        @button_name = ts("Create")
        @action = :create
        render :action => "bookmark_form_dynamic" 
      }
    end
  end

  # GET /bookmarks/1/edit
  def edit
    @bookmarkable = @bookmark.bookmarkable
    respond_to do |format|
      format.html
      format.js { 
        @button_name = ts("Update")
        @action = :update
        render :action => "bookmark_form_dynamic" 
      }
    end    
  end

  # POST /bookmarks
  # POST /bookmarks.xml
  def create
    @bookmark = Bookmark.new(params[:bookmark])
    @bookmarkable = @bookmark.bookmarkable 
    if @bookmarkable.new_record? && @bookmarkable.fandoms.blank?
       @bookmark.errors.add(:base, "Fandom tag is required")
       render :new and return
    end
    if @bookmarkable.save && @bookmark.save
      flash[:notice] = ts('Bookmark was successfully created.')
      redirect_to(@bookmark) and return
    end 
    @bookmarkable.errors.full_messages.each { |msg| @bookmark.errors.add(:base, msg) }
    render :action => "new" and return
  end

  # PUT /bookmarks/1
  # PUT /bookmarks/1.xml
  def update
    if @bookmark.update_attributes(params[:bookmark])
      flash[:notice] = ts("Bookmark was successfully updated.")
      redirect_to(@bookmark) 
    else
      @bookmarkable = @bookmark.bookmarkable
      render :action => :edit
    end
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.xml
  def destroy
    @bookmark.destroy
    flash[:notice] = ts("Bookmark was successfully deleted.")
    redirect_to user_bookmarks_path(current_user)
  end

  # Used on index page to show 4 most recent bookmarks (after bookmark being currently viewed) via RJS
  # Only main bookmarks page or tag bookmarks page
  # non-JS fallback should be to the 'view all bookmarks' link which serves the same function
  def fetch_recent
    @bookmarkable = @bookmark.bookmarkable
    respond_to do |format|
      format.js {
        @bookmarks = @bookmarkable.bookmarks.visible(:order => "created_at DESC").offset(1).limit(4)
      }
      format.html do
        id_symbol = (@bookmarkable.class.to_s.underscore + '_id').to_sym
        redirect_to url_for({:action => :index, id_symbol => @bookmarkable})
      end
    end
  end
  def hide_recent
    @bookmarkable = @bookmark.bookmarkable
  end

end
