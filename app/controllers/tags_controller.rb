class TagsController < ApplicationController
  before_filter :load_collection
  before_filter :check_user_status, :except => [ :show, :index, :show_hidden, :show_hidden_freeforms, :search ]
  before_filter :check_permission, :except => [ :show, :index, :show_hidden, :show_hidden_freeforms, :search ]

  def check_permission
    logged_in_as_admin? || permit?("tag_wrangler") || access_denied
  end

  # GET /tags
  # GET /tags.xml
  def index
    if @collection
      @tags = Freeform.canonical.for_collections([@collection] + @collection.children)
    else      
      @tags = Freeform.for_tag_cloud
    end

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end
  
  def search
    unless params[:query].blank?
      if params[:tag_type] && params[:tag_type] != 'All'
        @tags = params[:tag_type].singularize.constantize.search(params[:query], :order => "name ASC", :page => params[:page])
      else
        @tags = Tag.search(params[:query], :order => "type ASC, name ASC", :page => params[:page])
      end
    end    
  end  

  # if user is Admin or Tag Wrangler, show them details about the tag
  # if user is not logged in or a regular user, show them
  #   1. the works, if the tag had been wrangled and we can redirect them to works using it or its canonical merger
  #   2. the tag, the works and the bookmarks using it, if the tag is unwrangled (because we can't redirect them
  #       to the works controller)
  def show
    @tag = Tag.find_by_name(params[:id])
    if @tag.is_a? Tag
      if @tag.is_a?(Banned) && !logged_in_as_admin?
        flash[:error] = t('errors.log_in_as_admin', :default => "Please log in as admin")
        redirect_to tag_wranglings_path and return
      end
      # if tag is NOT wrangled, prepare to show works and bookmarks that are using it
      if !@tag.canonical && !@tag.merger
        if logged_in? #current_user.is_a?User
          @works = @tag.works.visible_to_user.paginate(:page => params[:page])
        elsif logged_in_as_admin?
          @works= @tag.works.visible_to_owner.paginate(:page => params[:page])
        else
          @works = @tag.works.visible_to_all.paginate(:page => params[:page])
        end
        @bookmarks = @tag.bookmarks.select{|b| b.visible}.paginate(:page => params[:page])
      end
      # if regular user or anonymous (not logged in) visitor, AND the tag is wrangled, just give them the goodies
      if !(logged_in? && current_user.is_tag_wrangler? || logged_in_as_admin?)
        if @tag.canonical # show works with that tag
          redirect_to url_for(:controller => :works, :action => :index, :tag_id => @tag) and return
        elsif @tag.merger # show works with the canonical merger (synonym) of that tag
          redirect_to url_for(:controller => :works, :action => :index, :tag_id => @tag.merger) and return
        end
      end
    else
      flash[:error] = t('not_found', :default => "Tag not found")
      redirect_to '/'
    end
  end

  def show_hidden
    unless params[:creation_id].blank? && params[:creation_type].blank?
      # Tags aren't directly on series, so we need to handle them differently
      if params[:creation_type] == 'Series'
        @display_creation = Series.find(params[:creation_id])
        @display_tags = @display_creation.works.visible.collect(&:warning_tags).flatten.compact.uniq
      else
        @display_creation = eval(params[:creation_type]).find(params[:creation_id])
        @display_tags = @display_creation.warnings
      end
      @display_category = @display_tags.first.class.name.downcase
    end
    if request.xml_http_request?
      respond_to do |format|
        format.js
      end
    else
      # This is just a quick fix to avoid script barf if JavaScript is disabled
      flash[:error] = t('need_javascript', :default => "Sorry, you need to have JavaScript enabled for this.")
      redirect_to :back
    end
  end

  def show_hidden_freeforms
    unless params[:creation_id].blank? && params[:creation_type].blank?
      # Tags aren't directly on series, so we need to handle them differently
      if params[:creation_type] == 'Series'
        @display_creation = Series.find(params[:creation_id])
        @display_tags = @display_creation.works.visible.collect(&:warning_tags).flatten.compact.uniq
      else
        @display_creation = eval(params[:creation_type]).find(params[:creation_id])
        @display_tags = @display_creation.freeforms
      end
      @display_category = @display_tags.first.class.name.downcase
    end
    if request.xml_http_request?
      respond_to do |format|
        format.js
      end
    else
      # This is just a quick fix to avoid script barf if JavaScript is disabled
      flash[:error] = t('need_javascript', :default => "Sorry, you need to have JavaScript enabled for this.")
      redirect_to :back
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
      @tag = type.constantize.find_or_create_by_name(params[:tag][:name])
    else
      flash[:error] = t('please_provide_category', :default => "Please provide a category.")
      @tag = Tag.new(:name => params[:tag][:name])
      render :action => "new" and return
    end
    if @tag.andand.valid?
      if (@tag.name != params[:tag][:name]) && (@tag.name.downcase == params[:tag][:name].downcase) # only capitalization different
        @tag.update_attribute(:name, params[:tag][:name])  # use the new capitalization
        flash[:notice] = t('successfully_modified', :default => 'Tag was successfully modified.')
      else
        flash[:notice] = t('successfully_created', :default => 'Tag was successfully created.')
      end
      @tag.update_attribute(:canonical, params[:tag][:canonical])
      redirect_to url_for(:controller => "tags", :action => "edit", :id => @tag)
    else
      render :action => "new" and return
    end
  end

  def edit
    @tag = Tag.find_by_name(params[:id])
    if @tag.is_a?(Banned) && !logged_in_as_admin?
      flash[:error] = t('errors.log_in_as_admin', :default => "Please log in as admin")
      redirect_to tag_wranglings_path and return
    end
    unless @tag
      raise ActiveRecord::RecordNotFound, "Couldn't find tag named '#{params[:id]}'"
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
      @wranglers = @tag.wranglers
    elsif @tag.respond_to?(:fandoms) && !@tag.fandoms.empty?
      @wranglers = @tag.fandoms.collect(&:wranglers).flatten.uniq
    end
  end

  def update
    @tag = Tag.find_by_name(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = t('successfully_updated', :default => 'Tag was updated.')
      if params[:commit] == "Wrangle"
        params[:page] = '1' if params[:page].blank?
        params[:sort] = 'name ASC' if params[:sort].blank?
        redirect_to url_for(:controller => :tags, :action => :wrangle, :id => params[:id], :show => params[:show], :page => params[:page], :sort => params[:sort])        
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
  
  def remove_association
    @tag = Tag.find_by_name(params[:id])
    unless @tag
      raise ActiveRecord::RecordNotFound, "Couldn't find tag named '#{params[:id]}'"
    end
    if params[:to_remove]   
      tag_to_remove = Tag.find_by_name(params[:to_remove])
      @tag.remove_association(tag_to_remove)
    end
    flash[:notice] = t('successfully_updated', :default => 'Tag was updated.')
    redirect_to url_for(:controller => "tags", :action => "edit", :id => @tag)    
  end
  
  def wrangle
    @tag = Tag.find_by_name(params[:id])
    unless @tag
      raise ActiveRecord::RecordNotFound, "Couldn't find tag named '#{params[:id]}'"
    end    
    @counts = {}
    @tag.child_types.map{|t| t.underscore.pluralize.to_sym}.each do |tag_type|      
      @counts[tag_type] = @tag.send(tag_type).count
    end
    unless params[:show].blank?
      sort = params[:sort] || 'name ASC' 
      if sort.include?('suggested')
        sort = sort + ", name ASC"
      end
      if %w(unfilterable canonical noncanonical).include?(params[:status])          
        @tags = @tag.send(params[:show]).send(params[:status]).find(:all, :order => sort).paginate(:page => params[:page], :per_page => 50)
      elsif params[:status] == "unwrangled"
        @tags = @tag.same_work_tags.unwrangled.by_type(params[:show].singularize.camelize).find(:all, :order => sort).paginate(:page => params[:page], :per_page => 50)
      else
        @tags = @tag.send(params[:show]).find(:all, :order => sort).paginate(:page => params[:page], :per_page => 50)
      end       
    end    
  end
  
  def mass_update
    params[:page] = '1' if params[:page].blank?
    params[:sort] = 'name ASC' if params[:sort].blank?
    unless params[:canonicals].blank?
      saved = []
      not_saved = []
      params[:canonicals].each do |tag_id|
        tag = Tag.find(tag_id)
        if tag.update_attributes(:canonical => true)
          saved << tag
        else
          not_saved << tag
        end
      end
      if not_saved.empty? && !saved.empty?
        flash[:notice] = "The following tags were successfully updated: #{saved.collect(&:name).join(', ')}"
      elsif !not_saved.empty?
        flash[:error] = "The following tags weren't saved: #{not_saved.collect(&:name).join(', ')}"
      end
    end
    redirect_to url_for(:controller => :tags, :action => :wrangle, :id => params[:id], :show => params[:show], :page => params[:page], :sort => params[:sort])            
  end  
end