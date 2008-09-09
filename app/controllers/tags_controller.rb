class TagsController < ApplicationController
  before_filter :check_user_status, :only => [:new, :create]

#permit('wranglers',
# :permission_denied_redirection => {:controller => :works, :action => :index },
# :permission_denied_message => 'Sorry, the page you have requested is for tag wranglers only! Please contact an admin if you think you should have access.',
# :except => [ :show, :index ]

  # GET /tags
  # GET /tags.xml
  def index
    if params[:search]
      category = TagCategory.find(params[:tag_category_id])
      @tags = category.tags.find(:all, :conditions => [ 'LOWER(name) LIKE ?', '%' + params[:search].strip + '%' ], :limit => 10)
    else
      @tags = Tag.find(:all, :order => "name")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end    
  end
  
  def show_hidden
    unless params[:work_id].blank? || params[:category_id].blank?
      @display_work = Work.find(params[:work_id])
      @display_category = TagCategory.find(params[:category_id])
      @display_tags = @display_work.tags.by_category(@display_category)
    end
    respond_to do |format|
      format.js
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])
    unless @tag.valid
      render :file => "#{RAILS_ROOT}/public/403.html",  :status => 403 and return
    end
    @tags = @tag.synonyms
    @works = @tag.works.visible(current_user) + @tags.collect {|tag| tag.works.visible(current_user)}.flatten
    @bookmarks = @tag.bookmarks.visible(current_user) + @tags.collect {|tag| tag.bookmarks.visible(current_user)}.flatten
    @ambiguous = @tag.disambiguation   

    @works.uniq!
    @bookmarks.uniq!
    @tag_categories = TagCategory.official
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
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        flash[:notice] = 'Tag was successfully created.'.t
        format.html { redirect_to tag_categories_path }
      else
        format.html { render :action => "new" }
      end
    end
  end

end
