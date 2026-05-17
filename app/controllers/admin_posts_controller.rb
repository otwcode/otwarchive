class AdminPostsController < Admin::BaseController

  before_action :admin_only, except: [:index, :show]
  before_action :load_languages, except: [:show, :destroy]
  before_action :load_admin_posts, only: [:index, :drafts]

  # GET /admin_posts
  def index
    @page_subtitle = t(".page_title")
    @admin_posts = @admin_posts.posted.order(published_at: :desc).page(params[:page])
  end

  # GET /admin_posts/drafts
  def drafts
    authorize AdminPost

    @page_subtitle = t(".page_title")
    @pagy, @admin_posts = pagy(@admin_posts.unposted.order(created_at: :desc))
  end

  # GET /admin_posts/1
  def show
    @admin_post = AdminPost.find(params[:id])
    authorize(@admin_post) unless @admin_post.posted?

    admin_posts = AdminPost.non_translated
    if @admin_post.posted?
      @admin_posts = admin_posts.posted.order(published_at: :desc).limit(8)
      @previous_admin_post = admin_posts.posted.order(published_at: :desc).where("published_at < ?", @admin_post.published_at).first
      @next_admin_post = admin_posts.posted.order(published_at: :asc).where("published_at > ?", @admin_post.published_at).first
    else
      @admin_posts = admin_posts.unposted.order(created_at: :desc).limit(8)
      @previous_admin_post = admin_posts.unposted.order(created_at: :desc).where("created_at < ?", @admin_post.created_at).first
      @next_admin_post = admin_posts.unposted.order(created_at: :asc).where("created_at > ?", @admin_post.created_at).first
    end
    @page_subtitle = @admin_post.title.html_safe
    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end

  # GET /admin_posts/1/preview
  def preview
    @preview_mode = true
    @admin_post = AdminPost.find(params[:id])
    authorize(@admin_post)
  end

  # GET /admin_posts/new
  # GET /admin_posts/new.xml
  def new
    @admin_post = AdminPost.new
    authorize @admin_post
  end

  # GET /admin_posts/1/edit
  def edit
    @admin_post = AdminPost.find(params[:id])
    authorize @admin_post
  end

  # POST /admin_posts
  def create
    @admin_post = AdminPost.new(admin_post_params)
    @admin_post.posted = true if params[:post_button] && !@admin_post&.translated_post&.draft?

    authorize @admin_post
    if params[:preview_button]
      @preview_mode = true
      render action: "preview"
    elsif !params[:edit_button] && @admin_post.save
      flash[:notice] = t(".success")
      redirect_to(admin_post_path(@admin_post))
    else
      render action: "new"
    end
  end

  # PUT /admin_posts/1
  def update
    @admin_post = AdminPost.find(params[:id])
    @admin_post.attributes = admin_post_params
    @admin_post.posted = true if params[:post_button] && !@admin_post&.translated_post&.draft?
    authorize @admin_post

    if !params[:edit_button] && @admin_post.valid?
      if params[:preview_button]
        @preview_mode = true
        render :preview and return
      elsif @admin_post.save
        flash[:notice] = t(".success")
        redirect_to(@admin_post) and return
      end
    end

    render action: "edit"
  end

  # PUT /admin_posts/1/post
  def post
    @admin_post = AdminPost.find(params[:id])
    authorize @admin_post

    @admin_post.posted = true

    if @admin_post.save
      flash[:notice] = t(".success")
      redirect_to @admin_post
    else
      flash[:error] = t(".error")
      redirect_to(edit_admin_post_path(@admin_post))
    end
  end

  # DELETE /admin_posts/1
  def destroy
    @admin_post = AdminPost.find(params[:id])
    authorize @admin_post
    @admin_post.destroy

    redirect_to(@admin_post.posted? ? admin_posts_path : drafts_admin_posts_path)
  end

  protected

  def load_languages
    @news_languages = Language.where(id: Locale.all.map(&:language_id)).default_order
  end

  def load_admin_posts
    @tag = AdminPostTag.find_by(id: params[:tag]) if params[:tag]
    @admin_posts = @tag&.admin_posts || AdminPost

    if params[:language_id].present? && (@language = Language.find_by(short: params[:language_id]))
      @admin_posts = @admin_posts.where(language_id: @language.id)
      @tags = AdminPostTag.distinct.joins(:admin_posts).where(admin_posts: { language_id: @language.id }).order(:name)
    else
      @admin_posts = @admin_posts.non_translated
      @tags = AdminPostTag.order(:name)
    end
  end

  private

  def admin_post_params
    params.require(:admin_post).permit(
      :admin_id, :title, :content, :translated_post_id, :language_id, :tag_list,
      :comment_permissions, :moderated_commenting_enabled
    )
  end
end
