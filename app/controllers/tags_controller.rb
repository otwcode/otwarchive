class TagsController < ApplicationController
  include TagWrangling

  before_action :load_collection
  before_action :check_user_status, except: [:show, :index, :show_hidden, :search, :feed]
  before_action :check_permission_to_wrangle, except: [:show, :index, :show_hidden, :search, :feed]
  before_action :load_tag, only: [:show, :edit, :update, :wrangle, :mass_update]
  around_action :record_wrangling_activity, only: [:create, :update, :mass_update]

  caches_page :feed

  def load_tag
    @tag = Tag.find_by_name!(params[:id])
  end

  # GET /tags
  def index
    if @collection
      @tags = Freeform.canonical.for_collections_with_count([@collection] + @collection.children)
      @page_subtitle = t(".collection_page_title", collection_title: @collection.title)
    else
      no_fandom = Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
      if no_fandom
        @tags = no_fandom.children.by_type("Freeform").first_class.limit(ArchiveConfig.TAGS_IN_CLOUD)
        # have to put canonical at the end so that it doesn't overwrite sort order for random and popular
        # and then sort again at the very end to make it alphabetic
        @tags = if params[:show] == "random"
                  @tags.random.canonical.sort
                else
                  @tags.popular.canonical.sort
                end
      else
        @tags = []
      end
    end
  end

  def search
    options = params[:tag_search].present? ? tag_search_params : {}
    options.merge!(page: params[:page]) if params[:page].present?
    @search = TagSearchForm.new(options)
    @page_subtitle = ts("Search Tags")

    return if params[:tag_search].blank?

    @page_subtitle = ts("Tags Matching '%{query}'", query: options[:name]) if options[:name].present?

    @tags = @search.search_results
    flash_search_warnings(@tags)
  end

  def show
    @page_subtitle = @tag.name
    if @tag.is_a?(Banned) && !logged_in_as_admin?
      flash[:error] = t("admin.access.not_admin_denied")
      redirect_to(tag_wranglings_path) && return
    end
    # if tag is NOT wrangled, prepare to show works, collections, and bookmarks that are using it
    if !@tag.canonical && !@tag.merger
      @works = if logged_in? # current_user.is_a?User
                 @tag.works.visible_to_registered_user.paginate(page: params[:page])
               elsif logged_in_as_admin?
                 @tag.works.visible_to_admin.paginate(page: params[:page])
               else
                 @tag.works.visible_to_all.paginate(page: params[:page])
               end
      @bookmarks = @tag.bookmarks.visible.paginate(page: params[:page])
      @collections = @tag.collections.paginate(page: params[:page])
    end

    return unless @tag.canonical
    
    child_types = @tag.child_types & %w[Character Relationship Freeform Fandom]
    unless child_types.empty?
      @tag_children = Rails.cache.fetch([:v1, :tag, :children, @tag.id], version: @tag.updated_at) do
        child_types.filter_map do |child_type|
          tags = TagQuery.new(type: child_type,
                              "#{@tag.class.name.downcase}_ids": [@tag.id],
                              sort_column: "uses",
                              page: 1,
                              per_page: ArchiveConfig.TAG_LIST_LIMIT).search_results.scope(:es_only)

          [child_type, tags] if tags.total_entries.positive?
        end.to_h
      end
    end

    @tag_mergers = Rails.cache.fetch([:v1, :tag, :mergers, @tag.id], version: @tag.updated_at) do
      results = TagQuery.new(type: @tag.type,
                             merger_id: @tag.id,
                             sort_column: "uses",
                             page: 1,
                             per_page: ArchiveConfig.TAG_LIST_LIMIT).search_results.scope(:es_only)
      results if results.total_entries.positive?
    end
  end

  def feed
    begin
      @tag = Tag.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise ActiveRecord::RecordNotFound, "Couldn't find tag with id '#{params[:id]}'"
    end
    @tag = @tag.merger if !@tag.canonical? && @tag.merger
    # Temp for testing
    if %w(Fandom Character Relationship).include?(@tag.type.to_s) || @tag.name == 'F/F'
      if @tag.canonical?
        @works = @tag.filtered_works.visible_to_all.order('created_at DESC').limit(25)
      else
        @works = @tag.works.visible_to_all.order('created_at DESC').limit(25)
      end
    else
      redirect_to(tag_works_path(tag_id: @tag.to_param)) && return
    end

    respond_to do |format|
      format.html
      format.atom
    end
  end

  def show_hidden
    unless params[:creation_id].blank? || params[:creation_type].blank? || params[:tag_type].blank?
      model = case params[:creation_type].downcase
              when "series"
                Series
              when "work"
                Work
              when "chapter"
                Chapter
              end
      @display_creation = model.find(params[:creation_id]) if model.is_a? Class

      # Tags aren't directly on series, so we need to handle them differently
      if params[:creation_type] == 'Series'
        if params[:tag_type] == 'warnings'
          @display_tags = @display_creation.works.visible.collect(&:archive_warnings).flatten.compact.uniq.sort
        else
          @display_tags = @display_creation.works.visible.collect(&:freeforms).flatten.compact.uniq.sort
        end
      else
        @display_tags = case params[:tag_type]
                        when 'warnings'
                          @display_creation.archive_warnings
                        when 'freeforms'
                          @display_creation.freeforms
                        end
      end

      # The string used in views/tags/show_hidden.js.erb
      if params[:tag_type] == 'warnings'
        @display_category = 'warnings'
      else
        @display_category = @display_tags.first.class.name.tableize
      end
    end

    respond_to do |format|
      format.html do
        # This is just a quick fix to avoid script barf if JavaScript is disabled
        flash[:error] = ts('Sorry, you need to have JavaScript enabled for this.')
        redirect_back_or_to root_path
      end
      format.js
    end
  end

  # GET /tags/new
  def new
    authorize :wrangling if logged_in_as_admin?

    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /tags
  def create
    type = tag_params[:type] if params[:tag]

    unless type
      flash[:error] = ts("Please provide a category.")
      @tag = Tag.new(name: tag_params[:name])
      render(action: "new")
      return
    end

    raise "Redshirt: Attempted to constantize invalid class initialize create #{type.classify}" unless Tag::TYPES.include?(type.classify)

    model = begin
              type.classify.constantize
            rescue StandardError
              nil
            end
    @tag = model.find_or_create_by_name(tag_params[:name]) if model.is_a? Class

    unless @tag&.valid?
      render(action: "new")
      return
    end

    if @tag.id_previously_changed? # i.e. tag is new
      @tag.update_attribute(:canonical, tag_params[:canonical])
      flash[:notice] = ts("Tag was successfully created.")
    else
      flash[:notice] = ts("Tag already existed and was not modified.")
    end

    redirect_to edit_tag_path(@tag)
  end

  def edit
    authorize :wrangling, :read_access? if logged_in_as_admin?

    @page_subtitle = ts('%{tag_name} - Edit', tag_name: @tag.name)

    if @tag.is_a?(Banned) && !logged_in_as_admin?
      flash[:error] = ts('Please log in as admin')

      redirect_to(tag_wranglings_path) && return
    end

    @counts = {}
    @uses = ["Works", "Drafts", "Bookmarks", "Private Bookmarks", "External Works", "Collections", "Taggings Count"]
    @counts['Works'] = @tag.visible_works_count
    @counts['Drafts'] = @tag.works.unposted.count
    @counts['Bookmarks'] = @tag.visible_bookmarks_count
    @counts['Private Bookmarks'] = @tag.bookmarks.not_public.count
    @counts['External Works'] = @tag.visible_external_works_count
    @counts["Collections"] = @tag.collections.count
    @counts['Taggings Count'] = @tag.taggings_count

    @parents = @tag.parents.order(:name).group_by { |tag| tag[:type] }
    @parents['MetaTag'] = @tag.direct_meta_tags.by_name
    @children = @tag.children.order(:name).group_by { |tag| tag[:type] }
    @children['SubTag'] = @tag.direct_sub_tags.by_name
    @children['Merger'] = @tag.mergers.by_name

    if @tag.respond_to?(:wranglers)
      @wranglers = @tag.canonical ? @tag.wranglers : (@tag.merger ? @tag.merger.wranglers : [])
    elsif @tag.respond_to?(:fandoms) && !@tag.fandoms.empty?
      @wranglers = @tag.fandoms.collect(&:wranglers).flatten.uniq
    end
    @suggested_fandoms = @tag.suggested_parent_tags("Fandom") - @tag.fandoms if @tag.respond_to?(:fandoms)
  end

  def update
    authorize :wrangling if logged_in_as_admin?

    # update everything except for the synonym,
    # so that the associations are there to move when the synonym is created
    syn_string = params[:tag].delete(:syn_string)
    new_tag_type = params[:tag].delete(:type)

    # Limiting the conditions under which you can update the tag type
    types = logged_in_as_admin? ? (Tag::USER_DEFINED + %w[Media]) : Tag::USER_DEFINED
    @tag = @tag.recategorize(new_tag_type) if @tag.can_change_type? && (types + %w[UnsortedTag]).include?(new_tag_type)

    unless params[:tag].empty?
      @tag.attributes = tag_params
    end

    @tag.syn_string = syn_string if @tag.errors.empty? && @tag.save

    if @tag.errors.empty? && @tag.save
      flash[:notice] = ts('Tag was updated.')
      redirect_to edit_tag_path(@tag)
    else
      @parents = @tag.parents.order(:name).group_by { |tag| tag[:type] }
      @parents['MetaTag'] = @tag.direct_meta_tags.by_name
      @children = @tag.children.order(:name).group_by { |tag| tag[:type] }
      @children['SubTag'] = @tag.direct_sub_tags.by_name
      @children['Merger'] = @tag.mergers.by_name

      render :edit
    end
  end

  def wrangle
    authorize :wrangling, :read_access? if logged_in_as_admin?

    @page_subtitle = ts('%{tag_name} - Wrangle', tag_name: @tag.name)
    @counts = {}
    @tag.child_types.map { |t| t.underscore.pluralize.to_sym }.each do |tag_type|
      @counts[tag_type] = @tag.send(tag_type).count
    end

    show = params[:show]
    if %w(fandoms characters relationships freeforms sub_tags mergers).include?(show)
      params[:sort_column] = 'name' unless valid_sort_column(params[:sort_column], 'tag')
      params[:sort_direction] = 'ASC' unless valid_sort_direction(params[:sort_direction])
      sort = params[:sort_column] + ' ' + params[:sort_direction]
      # add a secondary sorting key when the main one is not discerning enough
      if sort.include?('suggested') || sort.include?('taggings_count_cache')
        sort += ', name ASC'
      end
      # this makes sure params[:status] is safe
      status = params[:status]
      @tags = if %w[unfilterable canonical synonymous unwrangleable].include?(status)
                @tag.send(show).reorder(sort).send(status).paginate(page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE)
              elsif status == "unwrangled"
                @tag.unwrangled_tags(
                  params[:show].singularize.camelize,
                  params.permit!.slice(:sort_column, :sort_direction, :page)
                )
              else
                @tag.send(show).reorder(sort).paginate(page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE)
              end
    end
  end

  def mass_update
    authorize :wrangling if logged_in_as_admin?

    params[:page] = '1' if params[:page].blank?
    params[:sort_column] = 'name' unless valid_sort_column(params[:sort_column], 'tag')
    params[:sort_direction] = 'ASC' unless valid_sort_direction(params[:sort_direction])
    options = { show: params[:show], page: params[:page], sort_column: params[:sort_column], sort_direction: params[:sort_direction], status: params[:status] }

    error_messages = []
    notice_messages = []

    # make tags canonical if allowed
    if params[:canonicals].present? && params[:canonicals].is_a?(Array)
      saved_canonicals = []
      not_saved_canonicals = []
      tags = Tag.where(id: params[:canonicals])

      tags.each do |tag_to_canonicalize|
        if tag_to_canonicalize.update(canonical: true)
          saved_canonicals << tag_to_canonicalize
        else
          not_saved_canonicals << tag_to_canonicalize
        end
      end

      error_messages << ts('The following tags couldn\'t be made canonical: %{tags_not_saved}', tags_not_saved: not_saved_canonicals.collect(&:name).join(', ')) unless not_saved_canonicals.empty?
      notice_messages << ts('The following tags were successfully made canonical: %{tags_saved}', tags_saved: saved_canonicals.collect(&:name).join(', ')) unless saved_canonicals.empty?
    end

    # remove associated tags
    if params[:remove_associated].present? && params[:remove_associated].is_a?(Array)
      saved_removed_associateds = []
      not_saved_removed_associateds = []
      tags = Tag.where(id: params[:remove_associated])

      tags.each do |tag_to_remove|
        if @tag.remove_association(tag_to_remove.id)
          saved_removed_associateds << tag_to_remove
        else
          not_saved_removed_associateds << tag_to_remove
        end
      end

      error_messages << ts('The following tags couldn\'t be removed: %{tags_not_saved}', tags_not_saved: not_saved_removed_associateds.collect(&:name).join(', ')) unless not_saved_removed_associateds.empty?
      notice_messages << ts('The following tags were successfully removed: %{tags_saved}', tags_saved: saved_removed_associateds.collect(&:name).join(', ')) unless saved_removed_associateds.empty?
    end

    # wrangle to fandom(s)
    if params[:fandom_string].blank? && params[:selected_tags].is_a?(Array) && !params[:selected_tags].empty?
      error_messages << ts('There were no Fandom tags!')
    end
    if params[:fandom_string].present? && params[:selected_tags].is_a?(Array) && !params[:selected_tags].empty?
      canonical_fandoms = []
      noncanonical_fandom_names = []
      fandom_names = params[:fandom_string].split(',').map(&:squish)

      fandom_names.each do |fandom_name|
        if (fandom = Fandom.find_by_name(fandom_name)).try(:canonical?)
          canonical_fandoms << fandom
        else
          noncanonical_fandom_names << fandom_name
        end
      end

      if canonical_fandoms.present?
        saved_to_fandoms = Tag.where(id: params[:selected_tags])

        saved_to_fandoms.each do |tag_to_wrangle|
          canonical_fandoms.each do |fandom|
            tag_to_wrangle.add_association(fandom)
          end
        end

        canonical_fandom_names = canonical_fandoms.collect(&:name)
        options[:fandom_string] = canonical_fandom_names.join(',')
        notice_messages << ts('The following tags were successfully wrangled to %{canonical_fandoms}: %{tags_saved}', canonical_fandoms: canonical_fandom_names.join(', '), tags_saved: saved_to_fandoms.collect(&:name).join(', ')) unless saved_to_fandoms.empty?
      end

      if noncanonical_fandom_names.present?
        error_messages << ts('The following names are not canonical fandoms: %{noncanonical_fandom_names}.', noncanonical_fandom_names: noncanonical_fandom_names.join(', '))
      end
    end

    flash[:notice] = notice_messages.join('<br />').html_safe unless notice_messages.empty?
    flash[:error] = error_messages.join('<br />').html_safe unless error_messages.empty?

    redirect_to url_for({ controller: :tags, action: :wrangle, id: params[:id] }.merge(options))
  end

  private

  def tag_params
    params.require(:tag).permit(
      :name, :type, :canonical, :unwrangleable, :adult, :sortable_name,
      :meta_tag_string, :sub_tag_string, :merger_string, :syn_string,
      :media_string, :fandom_string, :character_string, :relationship_string,
      :freeform_string,
      associations_to_remove: []
    )
  end

  def tag_search_params
    params.require(:tag_search).permit(
      :query,
      :name,
      :fandoms,
      :type,
      :canonical,
      :wrangling_status,
      :created_at,
      :uses,
      :sort_column,
      :sort_direction
    )
  end
end
