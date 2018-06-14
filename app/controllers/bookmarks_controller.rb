class BookmarksController < ApplicationController
  before_action :load_collection
  before_action :load_owner, only: [ :index ]
  before_action :load_bookmarkable, only: [ :index, :new, :create, :fetch_recent, :hide_recent ]
  before_action :users_only, only: [:new, :create, :edit, :update]
  before_action :check_user_status, only: [:new, :create, :edit, :update]
  before_action :load_bookmark, only: [ :show, :edit, :update, :destroy, :fetch_recent, :hide_recent, :confirm_delete ]
  before_action :check_visibility, only: [ :show ]
  before_action :check_ownership, only: [ :edit, :update, :destroy, :confirm_delete ]

  before_action :check_pseud_ownership, only: [:create, :update]

  def check_pseud_ownership
    if params[:bookmark][:pseud_id]
      pseud = Pseud.find(bookmark_params[:pseud_id])
      unless pseud && current_user && current_user.pseuds.include?(pseud)
        flash[:error] = ts("You can't bookmark with that pseud.")
        redirect_to root_path and return
      end
    end
  end

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
    options = params[:bookmark_search].present? ? bookmark_search_params : {}
    options.merge!(page: params[:page]) if params[:page].present?
    options[:show_private] = false
    options[:show_restricted] = logged_in? || logged_in_as_admin?
    # ES UPGRADE TRANSITION #
    # Remove conditional and call to BookmarkSearch
    if use_new_search?
      @search = BookmarkSearchForm.new(options)
    else
      @search = BookmarkSearch.new(options)
    end
    @page_subtitle = ts("Search Bookmarks")
    if params[:bookmark_search].present? && params[:edit_search].blank?
      if @search.query.present?
        @page_subtitle = ts("Bookmarks Matching '%{query}'", query: @search.query)
      end
      @bookmarks = @search.search_results
      flash_max_search_results_notice(@bookmarks)
      render 'search_results'
    end
  end

  def index
    if @bookmarkable
      access_denied unless is_admin? || @bookmarkable.visible
      @bookmarks = @bookmarkable.bookmarks.is_public.paginate(page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE)
    else
      base_options = {
        show_private: (@user.present? && @user == current_user),
        show_restricted: logged_in? || logged_in_as_admin?,
        page: params[:page]
      }

      options = params[:bookmark_search].present? ? bookmark_search_params : {}

      if params[:include_bookmark_search].present?
        params[:include_bookmark_search].keys.each do |key|
          options[key] ||= []
          options[key] << params[:include_bookmark_search][key]
          options[key].flatten!
        end
      end

      if params[:exclude_bookmark_search].present?
        params[:exclude_bookmark_search].keys.each do |key|
          # Keep bookmarker tags separate, so we can search for them on bookmarks
          # and search for the rest on bookmarkables
          options_key = key == "tag_ids" ? :excluded_bookmark_tag_ids : :excluded_tag_ids
          options[options_key] ||= []
          options[options_key] << params[:exclude_bookmark_search][key]
          options[options_key].flatten!
        end
      end

      options.merge!(base_options)
      @page_subtitle = index_page_title

      if @owner.present?
        if @admin_settings.disable_filtering?
          @bookmarks = Bookmark.includes(:bookmarkable, :pseud, :tags, :collections).list_without_filters(@owner, options)
        else
          # ES UPGRADE TRANSITION #
          # Remove conditional and call to BookmarkSearch
          if use_new_search?
            @search = BookmarkSearchForm.new(options.merge(faceted: true, parent: @owner))
          else
            @search = BookmarkSearch.new(options.merge(faceted: true, bookmarks_parent: @owner))
          end

          if use_new_search? && @user.blank?
            # We're using the new search, but it's not a particular user's
            # bookmarks. That means that instead of the normal bookmark
            # listing, we want to list *bookmarkable* items.
            @bookmarkable_items = @search.bookmarkable_search_results
            flash_max_search_results_notice(@bookmarkable_items)
            @facets = @bookmarkable_items.facets
          else
            # Either we're using the old search, or we are looking at a
            # particular user's bookmarks. Either way, we want to just retrieve
            # the standard search results and their facets.
            @bookmarks = @search.search_results
            flash_max_search_results_notice(@bookmarks)
            @facets = @bookmarks.facets
          end

          if @search.options[:excluded_tag_ids].present? || @search.options[:excluded_bookmark_tag_ids].present?
            ids = [
              @search.options[:excluded_tag_ids],
              @search.options[:excluded_bookmark_tag_ids]
            ].flatten.compact

            tags = Tag.where(id: ids)
            excluded_bookmark_tag_ids = params.dig(:exclude_bookmark_search, :tag_ids) || []
            tags.each do |tag|
              if excluded_bookmark_tag_ids.include?(tag.id.to_s)
                key = 'tag'
              else
                key = tag.class.to_s.downcase
              end
              @facets[key] ||= []
              @facets[key] << QueryFacet.new(tag.id, tag.name, 0)
            end
          end
        end
      elsif use_caching?
        @bookmarks = Rails.cache.fetch("bookmarks/index/latest/v2_#{use_new_search?}", expires_in: 10.minutes) do
          # ES UPGRADE TRANSITION #
          # Remove conditional and call to BookmarkSearch
          if use_new_search?
            search = BookmarkSearchForm.new(show_private: false, show_restricted: false, sort_column: 'created_at')
          else
            search = BookmarkSearch.new(show_private: false, show_restricted: false, sort_column: 'created_at')
          end
          results = search.search_results
          flash_max_search_results_notice(results)
          @bookmarks = results.to_a
        end
      else
        @bookmarks = Bookmark.latest.includes(:bookmarkable, :pseud, :tags, :collections).to_a
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
        render action: "bookmark_form_dynamic"
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
        render action: "bookmark_form_dynamic"
      }
    end
  end

  # POST /bookmarks
  # POST /bookmarks.xml
  def create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmarkable = @bookmark.bookmarkable
    if @bookmarkable.new_record? && @bookmarkable.fandoms.blank?
       @bookmark.errors.add(:base, "Fandom tag is required")
       render :new and return
    end
    if @bookmark.errors.empty?
      if @bookmarkable.save && @bookmark.save
        flash[:notice] = ts('Bookmark was successfully created. It should appear in bookmark listings within the next few minutes.')
        redirect_to(@bookmark) and return
      end
    end
    @bookmarkable.errors.full_messages.each { |msg| @bookmark.errors.add(:base, msg) }
    render action: "new" and return
  end

  # PUT /bookmarks/1
  # PUT /bookmarks/1.xml
  def update
    new_collections = []
    unapproved_collections = []
    errors = []
    bookmark_params[:collection_names].split(',').map {|name| name.strip}.uniq.each do |collection_name|
      collection = Collection.find_by(name: collection_name)
      if collection.nil?
        errors << ts("#{collection_name} does not exist.")
      else
        if @bookmark.collections.include?(collection)
          next
        elsif collection.closed? && !collection.user_is_maintainer?(User.current_user)
          errors << ts("#{collection.title} is closed to new submissions.")
        elsif @bookmark.add_to_collection(collection) && @bookmark.save
          if @bookmark.approved_collections.include?(collection)
            new_collections << collection
          else
            unapproved_collections << collection
          end
        else
          errors << ts("Something went wrong trying to add collection #{collection.title}, sorry!")
        end
      end
    end

    # messages to the user
    unless errors.empty?
      flash[:error] = ts("We couldn't add your submission to the following collections: ") + errors.join("<br />")
    end

    flash[:notice] = "" unless new_collections.empty? && unapproved_collections.empty?
    unless new_collections.empty?
      flash[:notice] += ts("Added to collection(s): %{collections}.",
                          collections: new_collections.collect(&:title).join(", "))
    end
    unless unapproved_collections.empty?
      flash[:notice] ||= ""
      flash[:notice] += if unapproved_collections.size > 1
                          ts(" You have submitted your bookmark to moderated collections (%{all_collections}). It will not become a part of those collections until it has been approved by a moderator.", all_collections: unapproved_collections.map { |f| f.title }.join(', '))
                        else
                          ts(" You have submitted your bookmark to the moderated collection '%{collection}'. It will not become a part of the collection until it has been approved by a moderator.", collection: unapproved_collections.first.title)
                        end
    end

    flash[:notice] = (flash[:notice]).html_safe unless flash[:notice].blank?
    flash[:error] = (flash[:error]).html_safe unless flash[:error].blank?

    if errors.empty?
      if @bookmark.update_attributes(bookmark_params)
        flash[:notice] ||= ""
        flash[:notice] = ts(" Bookmark was successfully updated. ").html_safe + flash[:notice]
        flash[:notice] = (flash[:notice]).html_safe unless flash[:notice].blank?
        redirect_to(@bookmark)
      end
    else
      @bookmark.update_attributes(bookmark_params)
      @bookmarkable = @bookmark.bookmarkable
      render :edit and return
    end
  end

  def confirm_delete
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
        @bookmarks = @bookmarkable.bookmarks.visible.order("created_at DESC").offset(1).limit(4)
      }
      format.html do
        id_symbol = (@bookmarkable.class.to_s.underscore + '_id').to_sym
        redirect_to url_for({action: :index, id_symbol => @bookmarkable})
      end
    end
  end
  def hide_recent
    @bookmarkable = @bookmark.bookmarkable
  end

  protected

  def load_owner
    if params[:user_id].present?
      @user = User.find_by(login: params[:user_id])
      unless @user
        raise ActiveRecord::RecordNotFound, "Couldn't find user named '#{params[:user_id]}'"
      end
      if params[:pseud_id].present?
        @pseud = @user.pseuds.find_by(name: params[:pseud_id])
        unless @pseud
          raise ActiveRecord::RecordNotFound, "Couldn't find pseud named '#{params[:pseud_id]}'"
        end
      end
    end
    if params[:tag_id]
      @tag = Tag.find_by_name(params[:tag_id])
      unless @tag
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

  private

  def bookmark_params
    params.require(:bookmark).permit(
      :bookmarkable_id, :bookmarkable_type,
      :pseud_id, :notes, :tag_string, :collection_names, :private, :rec,
      external: [
        :url, :author, :title, :fandom_string, :rating_string, :relationship_string,
        :character_string, :summary, category_string: []
      ]
    )
  end

  def bookmark_search_params
    params.require(:bookmark_search).permit(
      # ES UPGRADE TRANSITION #
      # Remove fields for only BookmarkSearch: query, tag
      :query,
      :bookmark_query,
      :bookmarkable_query,
      :bookmarker,
      :bookmark_notes,
      :tag,
      :rec,
      :with_notes,
      :bookmarkable_type,
      :date,
      :bookmarkable_date,
      :sort_column,
      :other_tag_names,
      :excluded_tag_names,
      :other_bookmark_tag_names,
      :excluded_bookmark_tag_names,
      rating_ids: [],
      warning_ids: [],
      category_ids: [],
      fandom_ids: [],
      character_ids: [],
      relationship_ids: [],
      freeform_ids: [],
      tag_ids: [],
    )
  end

end
