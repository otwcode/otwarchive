class TagsController < ApplicationController

  before_filter :check_user_status, :except => [ :show, :index, :show_hidden ]
  before_filter :login_required, :except => [ :show, :index, :show_hidden ]
  def authorized?
    logged_in_as_admin? || permit?("tag_wrangler")
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
    unless @tag.is_a? Tag
        flash[:error] = "Tag not found"
        redirect_to tag_wranglings_path and return
    end
    if @tag.is_a?(Banned) && !logged_in_as_admin?
        flash[:error] = "Please log in as admin"
        redirect_to tag_wranglings_path and return
    end
    if !@tag.canonical && !@tag.merger
      if current_user.is_a?User
        @works = @tag.works.visible_to_user.paginate(:page => params[:page])
      else
        @works = @tag.works.visible_to_all.paginate(:page => params[:page])
      end
    end
  end

  def show_hidden
    unless params[:work_id].blank?
      @display_work = Work.find(params[:work_id])
      @display_tags = @display_work.warnings
      @display_category = @display_tags.first.type.downcase  # Enigel Dec 13 08 quick 'n dirty fix
    end
    if request.xml_http_request?
      respond_to do |format|
        format.js
      end
    else
      # This is just a quick fix to avoid script barf if JavaScript is disabled
      flash[:error] = "Sorry, you need to have JavaScript enabled for this.".t
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
      flash[:error] = "Please provide a category.".t
      @tag = Tag.new(:name => params[:tag][:name])
      render :action => "new" and return
    end
    if @tag.valid?
      if (@tag.name != params[:tag][:name]) && (@tag.name.downcase == params[:tag][:name].downcase) # only capitalization different
        @tag.update_attribute(:name, params[:tag][:name])  # use the new capitalization
        flash[:notice] = 'Tag was successfully modified.'.t
      else
        flash[:notice] = 'Tag was successfully created.'.t
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
        flash[:error] = "Please log in as admin"
        redirect_to tag_wranglings_path and return
    end
    if @tag.blank?
      flash[:error] = "Tag not found"
      redirect_to tag_wranglings_path and return
    end
  end

  def update
    @tag = Tag.find_by_name(params[:id])
    if @tag.blank?
      flash[:error] = "Tag not found"
      redirect_to root_path and return
    end
    if (params[:tag][:name] && logged_in_as_admin?)
      merger = @tag.type.constantize.find_by_name(params[:tag][:name])
      ambiguity = Tag.find_by_name(params[:tag][:name])
      if merger && (merger != @tag) # new name already exists as a separate tag in this category, merge them
        merger.update_fandoms(@tag.fandoms + merger.fandoms)
        merger.update_medias(@tag.medias + merger.medias)
        merger.wrangle_canonical
        @tag.wrangle_merger(merger)
      elsif ambiguity && (ambiguity != @tag) # new name already exists, but in different category
        flash[:error] = "Name already used in a different category"
      else
        @tag.update_attribute(:name, params[:tag][:name])
      end
    end
    @tag.update_type(params[:tag][:type], logged_in_as_admin?) if params[:tag][:type]
    @tag.update_attribute("canonical", params[:tag][:canonical]) if params[:tag][:canonical]

    fandoms = []
    fandoms << params[:fandom][:fandom_name] if params[:fandom]
    fandoms << params[:fandoms]
    @tag.update_fandoms(fandoms.compact)
    medias = []
    medias << params[:media][:media_name] if params[:media]
    medias << params[:media]
    @tag.update_medias(medias.compact)

    if @tag.merger_id && params[:keep_synonym].blank?
      @tag.update_attribute("merger_id", "")
    elsif !params[:new_synonym].blank?
      merger = @tag.type.constantize.find_or_create_by_name(params[:new_synonym])
      if merger == @tag # find on new synonym returned the same tag => only capitalization different
        @tag.update_attribute(:name, params[:new_synonym]) # use the new capitalization
      else # new (or possibly old) tag should be canonical
        merger.update_fandoms(@tag.fandoms + merger.fandoms)
        merger.update_medias(@tag.medias + merger.medias)
        merger.wrangle_canonical
      end
    else
      merger = Tag.find_by_id(params[:tag][:merger_id]) if params[:tag][:merger_id]
    end
    if merger.is_a? Tag
      @tag.wrangle_merger(merger)
    end
    @tag.update_freeforms(params[:freeforms])
    @tag.update_characters(params[:characters])
    @tag.update_pairings(params[:pairings])
    @tag.update_disambiguators(params[:disambiguators]) if params[:disambiguators]
    @tag.add_freeform(params[:freeform][:freeform_id]) if params[:freeform]
    @tag.add_character(params[:character][:character_id]) if params[:character]
    @tag.add_pairing(params[:pairing][:pairing_id]) if params[:pairing]
    @tag.add_synonym(params[:synonym][:synonym_id]) if params[:synonym]
    @tag.add_disambiguator(params[:disambiguator][:disambiguator_id]) if params[:disambiguator]
    @tag.update_common_tags
    flash[:notice] = 'Tag was updated.'.t
    redirect_to edit_tag_path(@tag.name)
  end
end
