class BookmarksController < ApplicationController 
  before_filter :load_collection
  before_filter :load_owner, :only => [ :index ]
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
    @languages = Language.default_order
    options = params[:bookmark_search] || {}
    options.merge!(page: params[:page]) if params[:page].present?
    options[:show_private] = false    
    options[:show_restricted] = current_user.present?
    @search = BookmarkSearch.new(options)
    @page_subtitle = ts("Search Bookmarks")
    if params[:bookmark_search].present? && params[:edit_search].blank?
      if @search.query.present?
        @page_subtitle = ts("Bookmarks Matching '%{query}'", query: @search.query)
      end
      @bookmarks = @search.search_results
      render 'search_results'
    end
  end

  def index
    if @bookmarkable
      access_denied unless is_admin? || @bookmarkable.visible
      @bookmarks = @bookmarkable.bookmarks.is_public.paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
    else
      if params[:bookmark_search].present?
        options = params[:bookmark_search].dup
      else
        options = {}
      end

      options[:show_private] = (@user.present? && @user == current_user)
      options[:show_restricted] = current_user.present?

      options.merge!(page: params[:page])      
      @page_subtitle = index_page_title

      if @owner.present?
        if @admin_settings.disable_filtering?
          @bookmarks = Bookmark.list_without_filters(@owner, options)
        else
          @search = BookmarkSearch.new(options.merge(faceted: true, bookmarks_parent: @owner))
          results = @search.search_results
          @bookmarks = @search.search_results
          @facets = @bookmarks.facets
        end
      elsif use_caching?
        @bookmarks = Rails.cache.fetch("bookmarks/index/latest/v1", :expires_in => 10.minutes) do
          search = BookmarkSearch.new(show_private: false, show_restricted: false, sort_column: 'created_at')
          results = search.search_results
          @bookmarks = search.search_results.to_a
        end
      else
        @bookmarks = Bookmark.latest.to_a
      end
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

  protected

  def load_owner
    if params[:user_id].present?
      @user = User.find_by_login(params[:user_id])
      if params[:pseud_id].present?
        @pseud = @user.pseuds.find_by_name(params[:pseud_id])
      end
    end
    if params[:tag_id]
      @tag = Tag.find_by_name(params[:tag_id])
      unless @tag && @tag.is_a?(Tag)
        raise ActiveRecord::RecordNotFound, "Couldn't find tag named '#{params[:tag_id]}'"
      end
      unless @tag.canonical?
        if @tag.merger.present?
          redirect_to tag_bookmarks_path(@tag.merger) and return
        else
          redirect_to tag_path(@tag) and return
        end
      end
    end
    @owner = @bookmarkable || @pseud || @user || @collection || @tag
  end

  def index_page_title
    if @owner.present?
      owner_name = case @owner.class.to_s
                   when 'Pseud'
                     @owner.name
                   when 'User'
                     @owner.login
                   when 'Collection'
                     @owner.title
                   else
                     @owner.try(:name)
                   end
      "#{owner_name} - Bookmarks".html_safe
    else
      "Latest Bookmarks"
    end
  end

end
