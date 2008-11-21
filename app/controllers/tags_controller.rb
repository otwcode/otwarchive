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
    @tag = Tag.find(params[:id])
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
    @tag = Tag.find(params[:id])
    @merge_possibilites = @tag.class.canonical.sort
    if @tag.merger
      render :action => "edit_merger" and return
    end
    if @tag.is_a?(Ambiguity)
      render :action => "edit_ambiguous" and return
    end
    @fandoms = Fandom.canonical.sort if @tag.class_name =~ /Character|Pairing|Freeform/
    @media = Media.canonical.sort if @tag.class_name =~ /Media/
    if @tag.canonical?
      @possible_children = @tag.possible_children(@tag.fandom)
      render :action => "edit_canonical" and return
    end
    render :action => "edit_unwrangled" and return
  end
  
  def update
    @tag = Tag.find(params[:id])
    commit = params[:commit]
    case commit
    when "Add Disambiguator"
      tag = Tag.find_by_id(params[:tag_id])
      tag.ambiguities << @tag
    when "Remove Disambiguator"
      tag_ids = params[:tag_ids]
      if tag_ids.blank?
        flash[:error] = "Please select some fandoms and a media"
      else
        tag_ids.each do |id|
          tag = Tag.find_by_id(id)
          tag.ambiguities.delete(@tag)
        end
      end
    when "Move Children to New Media"
      tag_ids = params[:tag_ids]
      media = Media.find_by_id(params[:media_id])
      if !media || tag_ids.blank?
        flash[:error] = "Please select some fandoms and a media"
      else
        tag_ids.each do |id| 
          fandom = Fandom.find_by_id(id)
          fandom.update_attribute(:media_id, media.id)
          fandom.update_attribute(:canonical, true)
          fandom.update_attribute(:wrangled, true)
        end
      end
    when "Move Children to New Fandom"
      tag_ids = params[:tag_ids]
      fandom = Fandom.find_by_id(params[:fandom_id])
      if !fandom || tag_ids.blank?
        flash[:error] = "Please select some tags and a fandom"
      else
        tag_ids.each do |id| 
          tag = Tag.find_by_id(id)
          tag.update_attribute(:fandom_id, fandom.id)
          tag.update_attribute(:wrangled, false)
        end
      end
    when "Mark Unwrangled Canonical"
      tag_ids = params[:tag_ids]
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
    when "Mark Unwrangled Ambiguous"
      tag_ids = params[:tag_ids]
      parent = Tag.find_by_id(params[:parent_id])
      if !parent || tag_ids.blank?
        flash[:error] = "Please select some tags and a parent"
      else
        tag_ids.each do |id|
          tag = Tag.find_by_id(id)
          tag.wrangle_parent(parent)
        end
      end
    when "Remove Parents and/or Children"
      tag_ids = params[:tag_ids]
      tag_ids.each do |id|
        tag = Tag.find_by_id(id)
        @tag.parents.delete(tag) if @tag.parents.include?(tag)
        tag.parents.delete(@tag) if tag.parents.include?(@tag)
      end
    when "Add Children"
      tag_ids = params[:tag_ids]
      tag_ids.each do |id|
        tag = Tag.find_by_id(id)
        tag.wrangle_parent(@tag)
      end
    when "Update Tag"
      if params[:tag][:name]
        if @tag.name != params[:tag][:name]
          old_tag = Tag.find_by_name(params[:tag][:name])
          if old_tag
            flash[:notice] = "The tag name has already been taken. Consider merging instead.".t
            render edit_tag_path(@tag) and return
          else
            @tag.update_attribute(:name, @tag.name)
          end
        end
      end
      if params[:tag][:canonical] == "1"
        @tag.wrangle_canonical
        @tag.update_attribute(:adult, params[:tag][:adult]) if params[:tag][:adult]
      else
        merger = Tag.find_by_id(params[:merger_id])
        @tag.wrangle_merger(merger) if merger    
        @tag.wrangle_not_canonical
        if params[:ambiguous] == "1"
          @tag.wrangle_ambiguous 
          redirect_to edit_tag_path(Ambiguity.find(@tag.id)) and return
        end
      end
      @tag.update_attribute(:wrangled, true)
    end #case
    flash[:notice] = 'Tag was successfully updated.'.t
    redirect_to edit_tag_path(@tag.reload)
  end
end
