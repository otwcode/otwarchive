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
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])
    unless @tag.valid
      render :file => "#{RAILS_ROOT}/public/403.html",  :status => 403 and return
    end

    @works = @tag.works.visible(current_user)
    @bookmarks = @tag.bookmarks.visible(current_user)
    @tags = @tag.visible('Tags', current_user)
    @ambiguous = @tag.disambiguates

    @tag.synonyms.each do |t|
      @works += t.visible('Works', current_user)
      @bookmarks += t.visible('Bookmarks', current_user)
      @tags += t.visible('Tags', current_user)
    end

    @tags = @tags - @tag.synonyms - [@tag] - @ambiguous

    @works.uniq!
    @bookmarks.uniq!
    @tags.uniq!

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
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
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

end
