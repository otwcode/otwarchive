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
    end
    respond_to do |format|
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
      @tag = type.constantize.find_or_create_by_name(params[:tag][:name])
    else
      flash[:error] = "Please provide a category.".t
      @tag = Tag.new(:name => params[:tag][:name])
      render :action => "new" and return
    end
    if @tag.valid?
      flash[:notice] = 'Tag was successfully created.'.t
      redirect_to edit_tag_path(@tag)
    else
      render :action => "new" and return
    end
  end 
  
  def edit
    @tag = Tag.find_by_name(params[:id])
    if @tag == Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
      if params[:only]
        if params[:only] == 'Banned'
          if logged_in_as_admin? 
            @unwrangled = Banned.all.sort
          else
            flash[:error] = "You have to be an admin"
            redirect :back and return
          end
        elsif params[:only] == 'Ambiguous'
            @unwrangled = Ambiguity.all.sort
        else
          @unwrangled = params[:only].constantize.unwrangled.no_fandom.sort
        end
      else
        @unwrangled = Freeform.unwrangled.no_fandom.sort
      end
      render :action => "unwrangled" and return
    elsif @tag.is_a?(Fandom)
      @unwrangled = @tag.children.select(&:unwrangled).group_by(&:type)
    end
    @fandoms = Fandom.canonical.sort if @tag.class_name =~ /Character|Pairing|Freeform/
    @medias = Media.canonical.sort if @tag.class_name =~ /Media/
    @possible_children = @tag.possible_children
  end
  
  def update
    @tag = Tag.find_by_name(params[:id])
    if params[:tag_ids]
      tag_ids = params[:tag_ids].keys
    end
    commit = params[:commit]
    case commit
    when "Remove Disambiguators"
      tag_ids.each do |id|
        tag = Tag.find_by_id(id)
        tag.ambiguities.delete(@tag)
      end
    when "Remove Parents and/or Children"
      tag_ids.each do |id|
        tag = Tag.find_by_id(id)
        @tag.parents.delete(tag) if @tag.parents.include?(tag)
        tag.parents.delete(@tag) if tag.parents.include?(@tag)       
        tag.update_attribute(:media_id, nil) if @tag.is_a?(Media)
        tag.update_attribute(:fandom_id, nil) if @tag.is_a?(Fandom)
      end
    when "Add Disambiguators"
      tag = Tag.find_by_id(params[:tag_id])
      tag.ambiguities << @tag
    when "Add Children"
      tag_ids.each do |id|
        tag = Tag.find_by_id(id)
        tag.wrangle_parent(@tag)
      end
    when "Mark Canonical"
      tag_ids.each do |id|
        tag = Tag.find_by_id(id)
        tag.wrangle_canonical
        if @tag.is_a?(Media)
          @tag.update_attribute(:media_id, @tag.id)
        elsif @tag.is_a?(Fandom) && tag[:type] =~ /Character|Pairing|Freeform/
          @tag.update_attribute(:fandom_id, @tag.id)
        end
        tag.update_attribute(:wrangled, true)
      end
    when "Mark Ambiguous"
      tag_ids.each do |id|
        tag = Tag.find_by_id(id)
        tag.wrangle_ambiguous
      end
    when "Move Remove from Fandom"
      tag_ids.each do |id| 
        tag = Tag.find_by_id(id)
        tag.update_attribute(:fandom_id, nil)
      end
    when "Add to Fandom"
      fandom = Fandom.find_by_id(params[:new_fandom_id])
      if tag_ids.blank? || !fandom
        flash[:error] = "Please select some tags and a fandom"
        render :action => :edit and return
      else
        tag_ids.each do |id|
          tag = Tag.find_by_id(id)
          tag.update_attribute(:fandom_id, fandom.id)
        end
      end
      redirect_to edit_tag_path(@tag, :only => params[:only]) and return
    when "Update Tag"
      if params[:tag][:name]
        if @tag.name != params[:tag][:name]
          old_tag = Tag.find_by_name(params[:tag][:name])
          if old_tag
            flash[:notice] = "The tag name has already been taken. Consider merging instead.".t
            render :action => :edit and return
          else
            @tag.update_attribute(:name, @tag.name)
          end
        end
      end
      @tag.update_attribute(:adult, params[:tag][:adult]) if params[:tag][:adult]
      if params[:ambiguous] == "1"
        @tag.wrangle_ambiguous
      end
      if params[:tag][:canonical] == "1"
        @tag.wrangle_canonical unless @tag.canonical?
      end
      if params[:tag][:canonical] == "0"
        @tag.wrangle_not_canonical if @tag.canonical?
      end
      merger = Tag.find_by_id(params[:merger_id])
      if merger
        @tag.wrangle_merger(merger) unless @tag.merger == merger
      end
      media = Media.find_by_id(params[:media_id])
      if media
        @tag.update_attribute(:media_id, media.id) unless @tag.media == media
      end
      fandom = Fandom.find_by_id(params[:fandom_id])
      if fandom
        @tag.update_attribute(:fandom_id, fandom.id) unless @tag.fandom == fandom
      end
      if params[:type] && logged_in_as_admin?
        @tag.update_attribute(:type, params[:type]) unless @tag.is_a?(params[:type].constantize)
      end
      @tag.update_attribute(:wrangled, true)
    end #case
    flash[:notice] = 'Tag was successfully updated.'.t
    redirect_to edit_tag_path(Tag.find_by_name(@tag.name))
  end
end
