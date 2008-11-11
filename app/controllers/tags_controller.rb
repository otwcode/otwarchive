class TagsController < ApplicationController
  before_filter :check_user_status, :only => [:new, :create]
  permit "tag_wrangler", :permission_denied_message => "Sorry, the page you tried to access is for authorized tag wranglers only.".t, :except => [ :show, :index, :show_hidden ]
  before_filter :check_user_status

  # GET /tags
  # GET /tags.xml
  def index
    if params[:search]
      category = TagCategory.find(params[:type])
      @tags = Tag.by_category([category]).find(:all, :conditions => [ 'LOWER(name) LIKE ?', '%' + params[:search].strip + '%' ], :limit => 10)
    else
      @tags = Tag.by_category("Freeform").ordered_by_name.valid
    end

    respond_to do |format|
      format.html # index.html.erb
      format.js
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

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])
    if @tag.banned?
  	  flash[:error] = 'This page is unavailable.'.t
      redirect_to tags_path and return
    end
    @tags = @tag.synonyms
    @works = Work.visible.with_any_tags(@tags + [@tag]).paginate(:page => params[:page])
    @bookmarks = @tag.bookmarks.visible + @tags.collect {|tag| tag.bookmarks.visible}.flatten

    @bookmarks.uniq!
    respond_to do |format|
      format.html # show.html.erb
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
      @tag = type.constantize.new(params[:tag])
    else
      flash[:notice] = "Please provide a category.".t
    @tag = Tag.new(params[:tag])
      render :action => "new" and return
    end
    if Tag.find(:first, :conditions => {:name => @tag.name, :type => @tag.type})
      flash[:notice] = "A tag by that name already exists in that category.".t
      redirect_to tag_wranglings_path    
    else
      respond_to do |format|
        if @tag.save
          flash[:notice] = 'Tag was successfully created.'.t
          format.html { redirect_to tag_wranglings_path }
        else
          format.html { render :action => "new" }
        end
      end
    end
  end 
  
  def edit
    @tag = Tag.find(params[:id])
  end
  
  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = 'Tag was successfully updated.'.t
      redirect_to tag_wranglings_path
    else
      flash[:error] = "Tag failed to save."
      format.html { render :action => "edit" }
    end
  end

end
