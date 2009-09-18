class AdminPostsController < ApplicationController
  
  before_filter :admin_only, :except => [:index, :show]
  
  include HtmlFormatter
  
  # GET /admin_posts
  # GET /admin_posts.xml
  def index
    @admin_posts = AdminPost.find(:all, :order => 'created_at DESC')
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_posts }
    end
  end
  
  # GET /admin_posts/1
  # GET /admin_posts/1.xml
  def show
    @admin_post = AdminPost.find(params[:id])
    @commentable = @admin_post
    @comments = @admin_post.comments
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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_post }
    end
  end

  # GET /admin_posts/1/edit
  def edit
    @admin_post = AdminPost.find(params[:id])
  end

  # POST /admin_posts
  # POST /admin_posts.xml
  def create
    @admin_post = AdminPost.new(params[:admin_post])

    respond_to do |format|
      if @admin_post.save
        flash[:notice] = 'AdminPost was successfully created.'
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
        flash[:notice] = 'AdminPost was successfully updated.'
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
