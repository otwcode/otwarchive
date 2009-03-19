class TagsController < ApplicationController

  before_filter :check_user_status, :except => [ :show, :index, :show_hidden ]
  before_filter :check_tag_wrangler_status, :except => [ :show, :index, :show_hidden ]

  def check_tag_wrangler_status
    return true if logged_in_as_admin? || permit?("tag_wrangler")
    if logged_in?
      flash[:error] = t('errors.tag_wranglers_only', :default => 'You have to be a tag wrangler to access this page')
      redirect_to current_user and return
    else
      store_location
      flash[:error] = t('errors.please_log_in', :default => 'Please log in.')
      redirect_to new_session_path and return
    end
  end

  # GET /tags
  # GET /tags.xml
  def index
    @tags = Tag.for_tag_cloud

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def show
    @tag = Tag.find_by_name(params[:id])
    if @tag.is_a? Tag
      if @tag.is_a?(Banned) && !logged_in_as_admin?
        flash[:error] = t('errors.log_in_as_admin', :default => "Please log in as admin")
        redirect_to tag_wranglings_path and return
      end
      if !@tag.canonical && !@tag.merger
        if current_user.is_a?User
          @works = @tag.works.visible_to_user.paginate(:page => params[:page])
        else
          @works = @tag.works.visible_to_all.paginate(:page => params[:page])
        end
      end
    else
      flash[:error] = t('errors.tags.not_found', :default => "Tag not found")
      redirect_to '/'
    end
  end

  def show_hidden
    unless params[:work_id].blank?
      @display_work = Work.find(params[:work_id])
      @display_tags = @display_work.warnings
      @display_category = @display_tags.first.class.name.downcase
    end
    if request.xml_http_request?
      respond_to do |format|
        format.js
      end
    else
      # This is just a quick fix to avoid script barf if JavaScript is disabled
      flash[:error] = t('errors.need_javascript', :default => "Sorry, you need to have JavaScript enabled for this.")
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
      flash[:error] = t('errors.tags.please_provide_category', :default => "Please provide a category.")
      @tag = Tag.new(:name => params[:tag][:name])
      render :action => "new" and return
    end
    if @tag.andand.valid?
      if (@tag.name != params[:tag][:name]) && (@tag.name.downcase == params[:tag][:name].downcase) # only capitalization different
        @tag.update_attribute(:name, params[:tag][:name])  # use the new capitalization
        flash[:notice] = t('notices.tags.successfully_modified', :default => 'Tag was successfully modified.')
     else
        flash[:notice] = t('notices.tags.successfully_created', :default => 'Tag was successfully created.')
     end
      @tag.update_attribute(:canonical, params[:tag][:canonical])
      redirect_to edit_tag_path(@tag)
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
    if @tag.blank?
      flash[:error] = t('errors.tags.not_found', :default => "Tag not found")
     redirect_to tag_wranglings_path and return
    end
  end

  def update
    @tag = Tag.find_by_name(params[:id].gsub(/%2F/, '/'))
    if @tag.blank?
      flash[:error] = t('errors.tags.not_found', :default => "Tag not found")
     redirect_to root_path and return
    end
    old_common_tag_ids = @tag.common_tags_to_add.map(&:id).sort

    if (params[:tag][:name] && logged_in_as_admin?)
      if ['Rating', 'Warning', 'Category'].include?(@tag[:type])
        flash[:error] = t('errors.tags.name_change', :default => "Name can't be changed from this interface.")
     else
        begin
          @tag.update_attribute(:name, params[:tag][:name])
        rescue
          @tag = Tag.find_by_name(params[:id]) # reset name
          flash[:error] = t('errors.tags.name_taken', :default => "Name already taken.")
       end
      end
    end
    @tag.update_type(params[:tag][:type], logged_in_as_admin?) if params[:tag][:type]
    @tag.update_attribute("canonical", params[:tag][:canonical]) if params[:tag][:canonical]
    @tag.update_attribute("adult", params[:tag][:adult]) if params[:tag][:adult] && logged_in_as_admin?

    fandoms = []
    fandoms << params[:fandom][:fandom_name] if params[:fandom]
    fandoms << params[:fandoms] if params[:fandoms]
    @tag.update_fandoms(fandoms.flatten.compact) if !fandoms.blank?
    medias = []
    medias << params[:media][:media_name] if params[:media]
    medias << params[:medias] if params[:medias]
    @tag.update_medias(medias.flatten.compact) if !medias.blank?
    freeforms = []
    freeforms << params[:freeform][:freeform_name] if params[:freeform]
    freeforms << params[:freeforms] if params[:freeforms]
    @tag.update_freeforms(freeforms.flatten.compact) if !freeforms.blank?
    characters = []
    characters << params[:character][:character_name] if params[:character]
    characters << params[:characters] if params[:characters]
    @tag.update_characters(characters.flatten.compact) if !characters.blank?
    pairings = []
    pairings << params[:pairing][:pairing_name] if params[:pairing]
    pairings << params[:pairings] if params[:pairings]
    @tag.update_pairings(pairings.flatten.compact) unless pairings.blank?
    synonyms = []
    synonyms << params[:synonym][:synonym_name] if params[:synonym]
    synonyms << params[:synonyms] if params[:synonyms]
    @tag.update_synonyms(synonyms.flatten.compact) unless synonyms.blank?
    disambiguators = []
    disambiguators << params[:disambiguator][:disambiguator_name] if params[:disambiguator]
    disambiguators << params[:disambiguators] if params[:disambiguators]
    @tag.update_disambiguators(disambiguators.flatten.compact) unless disambiguators.blank?

    if @tag.merger_id && params[:keep_synonym].blank?
      @tag.update_attribute("merger_id", "")
    elsif !params[:new_synonym].blank?
      merger = @tag.class.find_or_create_by_name(params[:new_synonym])
      if merger.id == @tag.id # find on new synonym returned the same tag => only capitalization different
        @tag.update_attribute(:name, params[:new_synonym]) # use the new capitalization
      else # new (or possibly old) tag should be canonical
        merger.wrangle_canonical
        fandoms = (@tag.fandoms + merger.fandoms).compact
        fandom_names = fandoms.map(&:name) unless fandoms.blank?
        merger.update_fandoms(fandom_names)
        medias = (@tag.medias + merger.medias).compact
        media_names = medias.map(&:name) unless medias.blank?
        merger.update_medias(media_names)
      end
    else
      merger = Tag.find_by_id(params[:tag][:merger_id]) if params[:tag][:merger_id]
    end
    if merger.is_a? Tag
      @tag.wrangle_merger(merger)
    end

    new_common_tag_ids = @tag.common_tags_to_add.map(&:id).sort
    @tag.update_common_tags unless old_common_tag_ids == new_common_tag_ids

    flash[:notice] = t('notices.tags.successfully_updated', :default => 'Tag was updated.')
    redirect_to :action => :edit
  end
end
