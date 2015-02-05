class AdminPostsController < ApplicationController

  before_filter :admin_only, :except => [:index, :show]

  # GET /admin_posts
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
  def show
    admin_posts = AdminPost.non_translated
    @admin_post = AdminPost.find_by_id(params[:id])
    unless @admin_post
      raise ActiveRecord::RecordNotFound, "Couldn't find admin post '#{params[:id]}'"
    end
    @admin_posts = admin_posts.order('created_at DESC').limit(8)
    @previous_admin_post = admin_posts.order('created_at DESC').where('created_at < ?', @admin_post.created_at).first
    @next_admin_post = admin_posts.order('created_at ASC').where('created_at > ?', @admin_post.created_at).first
    @commentable = @admin_post
    @comments = @admin_post.comments
    @page_subtitle = @admin_post.title.html_safe
    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end

  # GET /admin_posts/new
  # GET /admin_posts/new.xml
  def new
    @admin_post = AdminPost.new
  end

  # GET /admin_posts/1/edit
  def edit
    @admin_post = AdminPost.find(params[:id])
  end

  # POST /admin_posts
  def create
    @admin_post = AdminPost.new(params[:admin_post])
    if @admin_post.save
      flash[:notice] = ts("Admin Post was successfully created.")
      redirect_to(@admin_post)
    else
      render :action => "new"
    end
  end

  # PUT /admin_posts/1
  def update
    @admin_post = AdminPost.find(params[:id])

    if @admin_post.update_attributes(params[:admin_post])
      flash[:notice] = ts("Admin Post was successfully updated.")
      redirect_to(@admin_post)
    else
      render :action => "edit"
    end
  end

  # DELETE /admin_posts/1
  def destroy
    @admin_post = AdminPost.find(params[:id])
    @admin_post.destroy
    redirect_to(admin_posts_url)
  end
end
