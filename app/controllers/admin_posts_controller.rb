class AdminPostsController < ApplicationController

  before_filter :admin_only, :except => [:index, :show]
  
  # GET /admin_posts
  # GET /admin_posts.xml
  def index
    if params[:tag]
      @tag = AdminPostTag.find_by_id(params[:tag])
      if @tag
        @admin_posts = @tag.admin_posts
      end
    end
    @admin_posts ||= AdminPost
    if params[:language_id].present? && (@language = Language.find_by_short(params[:language_id]))
      @admin_posts = @admin_posts.where(:language_id => @language.id)
      @tags = AdminPostTag.where(:language_id => @language.id).order(:name)
    else
      @admin_posts = @admin_posts.non_translated
      @tags = AdminPostTag.order(:name)
    end
    @admin_posts = @admin_posts.order('created_at DESC').page(params[:page])
  end

  # GET /admin_posts/1
  # GET /admin_posts/1.xml
  def show
    admin_posts = AdminPost.non_translated
    @admin_posts = admin_posts.order('created_at DESC').limit(8)
    @admin_post = AdminPost.find_by_id(params[:id])
    unless @admin_post
      flash[:error] = ts("We couldn't find that admin post.")
      redirect_to admin_posts_path and return
    end
    @previous_admin_post = admin_posts.order('created_at DESC').where('created_at < ?', @admin_post.created_at).first
    @next_admin_post = admin_posts.order('created_at ASC').where('created_at > ?', @admin_post.created_at).first
    @commentable = @admin_post
    @comments = @admin_post.comments
    @page_subtitle = @admin_post.try(:title)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin_post }
      format.js
    end
  end

  # GET /admin_posts/new
  # GET /admin_posts/new.xml
  def new
    @admin_post = AdminPost.new
    @translatable_posts = AdminPost.non_translated.order("created_at DESC").limit(10)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_post }
    end
  end

  # GET /admin_posts/1/edit
  def edit
    @admin_post = AdminPost.find(params[:id])
    @translatable_posts = AdminPost.non_translated.order("created_at DESC").limit(10)
  end

  # POST /admin_posts
  # POST /admin_posts.xml
  def create
    @admin_post = AdminPost.new(params[:admin_post])

    respond_to do |format|
      if @admin_post.save
        flash[:notice] = ts("Admin Post was successfully created.")
        format.html { redirect_to(@admin_post) }
        format.xml  { render :xml => @admin_post, :status => :created, :location => @admin_post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_posts/1
  # PUT /admin_posts/1.xml
  def update
    @admin_post = AdminPost.find(params[:id])

    respond_to do |format|
      if @admin_post.update_attributes(params[:admin_post])
        flash[:notice] = ts("Admin Post was successfully updated.")
        format.html { redirect_to(@admin_post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @admin_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_posts/1
  # DELETE /admin_posts/1.xml
  def destroy
    @admin_post = AdminPost.find(params[:id])
    @admin_post.destroy

    respond_to do |format|
      format.html { redirect_to(admin_posts_url) }
      format.xml  { head :ok }
    end
  end
end
