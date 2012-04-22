class TagsController < ApplicationController
  before_filter :load_collection
  before_filter :check_user_status, :except => [ :show, :index, :show_hidden, :search, :feed ]
  before_filter :check_permission_to_wrangle, :except => [ :show, :index, :show_hidden, :search, :feed ]
  before_filter :load_tag, :only => [:show, :edit, :update, :wrangle, :mass_update]

  caches_page :feed

  cache_sweeper :tag_sweeper

  def load_tag
    @tag = Tag.find_by_name(params[:id])
    unless @tag && @tag.is_a?(Tag)
      raise ActiveRecord::RecordNotFound, "Couldn't find tag named '#{params[:id]}'"
    end
  end


  # GET /tags
  # GET /tags.xml
  def index
    if @collection
      @tags = Freeform.canonical.for_collections_with_count([@collection] + @collection.children)
    else
      no_fandom = Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
      @tags = no_fandom.children.by_type("Freeform").first_class.limit(ArchiveConfig.TAGS_IN_CLOUD)
      # have to put canonical at the end so that it doesn't overwrite sort order for random and popular
      # and then sort again at the very end to make it alphabetic
      if params[:show] == "random"
        @tags = @tags.random.canonical.sort
      else
        @tags = @tags.popular.canonical.sort
      end
    end
  end

  def search
    @query = {}
    if params[:query]
      @query = Query.standardize(params[:query])
      begin
        page = params[:page] || 1
        errors, @tags = Query.search_with_sphinx(Tag, @query, page)
        flash.now[:error] = errors.join(" ") unless errors.blank?
      rescue Riddle::ConnectionError
        flash.now[:error] = ts("The search engine seems to be down at the moment, sorry!")
      end
    end
  end

  # if user is Admin or Tag Wrangler, show them details about the tag
  # if user is not logged in or a regular user, show them
  #   1. the works, if the tag had been wrangled and we can redirect them to works using it or its canonical merger
  #   2. the tag, the works and the bookmarks using it, if the tag is unwrangled (because we can't redirect them
  #       to the works controller)
  def show
    if @tag.is_a?(Banned) && !logged_in_as_admin?
      flash[:error] = ts("Please log in as admin")
      redirect_to tag_wranglings_path and return
    end
    # if tag is NOT wrangled, prepare to show works and bookmarks that are using it
    if !@tag.canonical && !@tag.merger
      if logged_in? #current_user.is_a?User
        @works = @tag.works.visible_to_registered_user.paginate(:page => params[:page])
      elsif logged_in_as_admin?
        @works= @tag.works.visible_to_owner.paginate(:page => params[:page])
      else
        @works = @tag.works.visible_to_all.paginate(:page => params[:page])
      end
      @bookmarks = @tag.bookmarks.visible.paginate(:page => params[:page])
    end
    # if regular user or anonymous (not logged in) visitor, AND the tag is wrangled, just give them the goodies
    if !(logged_in? && current_user.is_tag_wrangler? || logged_in_as_admin?)
      if @tag.canonical # show works with that tag
        redirect_to url_for(:controller => :works, :action => :index, :tag_id => @tag) and return
      elsif @tag.merger # show works with the canonical merger (synonym) of that tag
        redirect_to url_for(:controller => :works, :action => :index, :tag_id => @tag.merger) and return
      end
    end
  end

  def feed
    begin
      @tag = Tag.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = ts("Tag not found!")
      redirect_back_or_default(tags_path)
      return
    end
    if !@tag.canonical? && @tag.merger
      @tag = @tag.merger
    end
    # Temp for testing
    if %w(Fandom Character Relationship).include?(@tag.type.to_s) || @tag.name == "F/F"
      if @tag.canonical?
        @works = @tag.filtered_works.visible_to_all.order("created_at DESC").limit(25)
      else
        @works = @tag.works.visible_to_all.order("created_at DESC").limit(25)
      end
    else
      redirect_to tag_works_path(:tag_id => @tag.to_param) and return
    end

    respond_to do |format|
      format.html
      format.atom
    end
  end

  def show_hidden
    unless params[:creation_id].blank? || params[:creation_type].blank? || params[:tag_type].blank?
      model = params[:creation_type].classify.constantize rescue nil
      @display_creation = model.find(params[:creation_id]) if model.is_a? Class
      # Tags aren't directly on series, so we need to handle them differently
      if params[:creation_type] == 'Series'
        if params[:tag_type] == 'warnings'
          @display_tags = @display_creation.works.visible.collect(&:warning_tags).flatten.compact.uniq.sort
        else
          @display_tags = @display_creation.works.visible.collect(&:freeform_tags).flatten.compact.uniq.sort
        end
      else
        if %w(warnings freeforms).include?(params[:tag_type])
          @display_tags = @display_creation.send(params[:tag_type]).sort
        end
      end
      @display_category = @display_tags.first.class.name.downcase.pluralize
    end
    respond_to do |format|
      format.html do
        # This is just a quick fix to avoid script barf if JavaScript is disabled
        flash[:error] = ts("Sorry, you need to have JavaScript enabled for this.")
        if request.env["HTTP_REFERER"]
          redirect_to(request.env["HTTP_REFERER"] || root_path)
        else
          # else branch needed to deal with bots, which don't have a referer
          redirect_to '/'
        end
      end
      format.js
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /tags
  # POST /tags.xml
  def create
    type = params[:tag][:type] if params[:tag]
    if type
      model = type.classify.constantize rescue nil
      @tag = model.find_or_create_by_name(params[:tag][:name])  if model.is_a? Class
    else
      flash[:error] = ts("Please provide a category.")
      @tag = Tag.new(:name => params[:tag][:name])
      render :action => "new" and return
    end
    if @tag && @tag.valid?
      if (@tag.name != params[:tag][:name]) && (@tag.name.downcase == params[:tag][:name].downcase) # only capitalization different
        @tag.update_attribute(:name, params[:tag][:name])  # use the new capitalization
        flash[:notice] = ts("Tag was successfully modified.")
      else
        flash[:notice] = ts("Tag was successfully created.")
      end
      @tag.update_attribute(:canonical, params[:tag][:canonical])
      redirect_to url_for(:controller => "tags", :action => "edit", :id => @tag)
    else
      render :action => "new" and return
    end
  end

  def edit
    if @tag.is_a?(Banned) && !logged_in_as_admin?
      flash[:error] = ts("Please log in as admin")
      redirect_to tag_wranglings_path and return
    end
    @counts = {}
    @uses = ['Works', 'Drafts', 'Bookmarks', 'Private Bookmarks', 'External Works']
    @counts['Works'] = @tag.visible_works_count
    @counts['Drafts'] = @tag.works.unposted.count
    @counts['Bookmarks'] = @tag.visible_bookmarks_count
    @counts['Private Bookmarks'] = @tag.bookmarks.not_public.count
    @counts['External Works'] = @tag.visible_external_works_count

    @parents = @tag.parents.find(:all, :order => :name).group_by {|tag| tag[:type]}
    @parents['MetaTag'] = @tag.direct_meta_tags.by_name
    @children = @tag.children.find(:all, :order => :name).group_by {|tag| tag[:type]}
    @children['SubTag'] = @tag.direct_sub_tags.by_name
    @children['Merger'] = @tag.mergers.by_name
    if @tag.respond_to?(:wranglers)
      @wranglers = @tag.canonical ? @tag.wranglers : (@tag.merger ? @tag.merger.wranglers : [])
    elsif @tag.respond_to?(:fandoms) && !@tag.fandoms.empty?
      @wranglers = @tag.fandoms.collect(&:wranglers).flatten.uniq
    end
    @suggested_fandoms = @tag.suggested_fandoms - @tag.fandoms if @tag.respond_to?(:fandoms)
  end

  def update
    # update everything except for the synonym,
    # so that the associations are there to move when the synonym is created
    syn_string = params[:tag].delete(:syn_string)
    @tag.attributes = params[:tag]
    @tag.syn_string = syn_string if @tag.save
    if @tag.errors.empty? && @tag.save
      flash[:notice] = ts('Tag was updated.')
      if params[:commit] == "Wrangle"
        params[:page] = '1' if params[:page].blank?
        params[:sort_column] = 'name' if !valid_sort_column(params[:sort_column], "tag")
        params[:sort_direction] = 'ASC' if !valid_sort_direction(params[:sort_direction])
        redirect_to url_for(:controller => :tags, :action => :wrangle, :id => params[:id], :show => params[:show], :page => params[:page], :sort_column => params[:sort_column], :sort_direction => params[:sort_direction], :status => params[:status])
      else
        redirect_to url_for(:controller => "tags", :action => "edit", :id => @tag)
      end
    else
      @parents = @tag.parents.find(:all, :order => :name).group_by {|tag| tag[:type]}
      @parents['MetaTag'] = @tag.direct_meta_tags.by_name
      @children = @tag.children.find(:all, :order => :name).group_by {|tag| tag[:type]}
      @children['SubTag'] = @tag.direct_sub_tags.by_name
      @children['Merger'] = @tag.mergers.by_name
      render :edit
    end
  end

  def wrangle
    @counts = {}
    @tag.child_types.map{|t| t.underscore.pluralize.to_sym}.each do |tag_type|
      @counts[tag_type] = @tag.send(tag_type).count
    end

    if %w(fandoms characters relationships freeforms sub_tags mergers).include?(params[:show])
      params[:sort_column] = 'name' if !valid_sort_column(params[:sort_column], 'tag')
      params[:sort_direction] = 'ASC' if !valid_sort_direction(params[:sort_direction])
      sort = params[:sort_column] + " " + params[:sort_direction]
      if sort.include?('suggested')
        sort = sort + ", name ASC"
      end
      # this makes sure params[:status] is safe
      if %w(unfilterable canonical noncanonical).include?(params[:status])
        @tags = @tag.send(params[:show]).order(sort).send(params[:status]).paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
      elsif params[:status] == "unwrangled"
        @tags = @tag.same_work_tags.unwrangled.by_type(params[:show].singularize.camelize).order(sort).paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
      else
        @tags = @tag.send(params[:show]).find(:all, :order => sort).paginate(:page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
      end
    end
  end

  def mass_update
    params[:page] = '1' if params[:page].blank?
    params[:sort_column] = 'name' if !valid_sort_column(params[:sort_column], 'tag')
    params[:sort_direction] = 'ASC' if !valid_sort_direction(params[:sort_direction])

    saved = []
    not_saved = []
    
    # make tags canonical
    unless params[:canonicals].blank?
      params[:canonicals].each do |tag_id|
        tag = Tag.find(tag_id)
        if tag.update_attributes(:canonical => true)
          saved << tag
        else
          not_saved << tag
        end
      end
    end

    # remove associated tags
    unless params[:remove_associated].blank?      
      params[:remove_associated].each do |tag_id|
        tag_to_remove = Tag.find(tag_id)
        if tag_to_remove
          @tag.remove_association(tag_to_remove)
          saved << tag_to_remove
        end
      end
    end

    flash[:notice] = ts("The following tags were successfully updated: %{tags_saved}", :tags_saved => saved.collect(&:name).join(', ')) if !saved.empty?
    flash[:error] = ts("The following tags weren't saved: %{tags_not_saved}", :tags_not_saved => not_saved.collect(&:name).join(', ')) if !not_saved.empty?

    redirect_to url_for(:controller => :tags, :action => :wrangle, :id => params[:id], :show => params[:show], :page => params[:page], :sort_column => params[:sort_column], :sort_direction => params[:sort_direction], :status => params[:status])
  end
  
end
