class TagsController < ApplicationController

#permit('wranglers',
# :permission_denied_redirection => {:controller => :works, :action => :index },
# :permission_denied_message => 'Sorry, the page you have requested is for tag wranglers only! Please contact an admin if you think you should have access.',
# :except => [ :show, :index ]

  # GET /tags
  # GET /tags.xml
  def index
    @tags = Tag.find(:all, :order => "name")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])
    @ambiguous = @tag.disambiguates
    @works = @tag.tagees('Works')
    @bookmarks = @tag.tagees('Bookmarks')
    @tags = @tag.tagees('Tags')
    @tag.synonyms.each do |t|
      @works += t.tagees('Works')
      @bookmarks += t.tagees('Bookmarks')
      @tags += t.tagees('Tags')
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
        flash[:notice] = 'Tag was successfully created.'
        format.html { redirect_to tag_relationships_path }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

end
