class CommentsController < ApplicationController
  skip_before_action :store_location, except: [:show, :index, :new]
  before_action :load_commentable, only: [ :index, :new, :create, :edit, :update,
                                              :show_comments, :hide_comments, :add_comment,
                                              :cancel_comment, :add_comment_reply,
                                              :cancel_comment_reply,
                                              :delete_comment, :cancel_comment_delete, :unreviewed, :review_all ]
  before_action :check_user_status, only: [:new, :create, :edit, :update, :destroy]
  before_action :load_comment, only: [:show, :edit, :update, :delete_comment, :destroy, :cancel_comment_edit, :cancel_comment_delete, :review, :approve, :reject]
  before_action :check_visibility, only: [:show]
  before_action :check_if_restricted
  before_action :check_tag_wrangler_access
  before_action :check_pseud_ownership, only: [:create, :update]
  before_action :check_ownership, only: [:edit, :update, :cancel_comment_edit]
  before_action :check_permission_to_edit, only: [:edit, :update ]
  before_action :check_permission_to_delete, only: [:delete_comment, :destroy]
  before_action :check_anonymous_comment_preference, only: [:new, :create, :add_comment_reply]
  before_action :check_unreviewed, only: [:add_comment_reply]
  before_action :check_permission_to_review, only: [:unreviewed]
  before_action :check_permission_to_access_single_unreviewed, only: [:show]
  before_action :check_permission_to_moderate, only: [:approve, :reject]

  cache_sweeper :comment_sweeper

  def check_pseud_ownership
    if params[:comment][:pseud_id]
      pseud = Pseud.find(comment_params[:pseud_id])
      unless pseud && current_user && current_user.pseuds.include?(pseud)
        flash[:error] = ts("You can't comment with that pseud.")
        redirect_to root_path and return
      end
    end
  end

  def load_comment
    @comment = Comment.find(params[:id])
    @check_ownership_of = @comment
    @check_visibility_of = @comment
  end

  def find_parent
    if @comment.present?
      @comment.ultimate_parent
    elsif @commentable.present? && @commentable.respond_to?(:work)
      @commentable.work
    else
      @commentable
    end
  end

  # Check to see if the ultimate_parent is a Work, and if so, if it's restricted
  def check_if_restricted
    parent = find_parent
    if parent.respond_to?(:restricted) && parent.restricted? && ! (logged_in? || logged_in_as_admin?)
      redirect_to login_path(restricted_commenting: true) and return
    end
  end

  # Check to see if the ultimate_parent is a Work, and if so, if it allows anon comments
  def check_anonymous_comment_preference
    parent = find_parent
    if parent.respond_to?(:anon_commenting_disabled) && parent.anon_commenting_disabled && !logged_in?
      flash[:error] = ts("Sorry, this work doesn't allow non-Archive users to comment.")
      redirect_to work_path(parent)
    end
  end

  def check_unreviewed
    if @commentable && @commentable.respond_to?(:unreviewed?) && @commentable.unreviewed?
      flash[:error] = ts("Sorry, you cannot reply to an unapproved comment.")
      if logged_in?
        redirect_to root_path and return
      else
        redirect_to login_path and return
      end
    end
  end

  def check_permission_to_review
    parent = find_parent
    unless logged_in_as_admin? || current_user_owns?(parent)
      flash[:error] = ts("Sorry, you don't have permission to see those unreviewed comments.")
      if logged_in?
        redirect_to root_path and return
      else
        redirect_to login_path and return
      end
    end
  end

  def check_permission_to_access_single_unreviewed
    if @comment.unreviewed?
      parent = find_parent
      unless logged_in_as_admin? || current_user_owns?(parent) || current_user_owns?(@comment)
        flash[:error] = ts("Sorry, that comment is currently in moderation.")
        if logged_in?
          redirect_to root_path and return
        else
          redirect_to login_path and return
        end
      end
    end
  end

  def check_permission_to_moderate
    parent = find_parent
    unless logged_in_as_admin? || current_user_owns?(parent)
      flash[:error] = ts("Sorry, you don't have permission to moderate that comment.")
      redirect_to(logged_in? ? root_path : login_path)
    end
  end

  def check_tag_wrangler_access
    if @commentable.is_a?(Tag) || (@comment && @comment.parent.is_a?(Tag))
      logged_in_as_admin? || permit?("tag_wrangler") || access_denied
    end
  end

  # Must be able to delete other people's comments on owned works, not just owned comments!
  def check_permission_to_delete
    access_denied(redirect: @comment) unless logged_in_as_admin? || current_user_owns?(@comment) || current_user_owns?(@comment.ultimate_parent)
  end

  # Comments cannot be edited after they've been replied to
  def check_permission_to_edit
    unless @comment && @comment.count_all_comments == 0
      flash[:error] = ts('Comments with replies cannot be edited')
      redirect_to(request.env["HTTP_REFERER"] || root_path) and return
    end
  end

  # Get the thing the user is trying to comment on
  def load_commentable
    @thread_view = false
    if params[:comment_id]
      @thread_view = true
      if params[:id]
        @commentable = Comment.find(params[:id])
        @thread_root = Comment.find(params[:comment_id])
      else
        @commentable = Comment.find(params[:comment_id])
        @thread_root = @commentable
      end
    elsif params[:chapter_id]
      @commentable = Chapter.find(params[:chapter_id])
    elsif params[:work_id]
      @commentable = Work.find(params[:work_id])
    elsif params[:admin_post_id]
      @commentable = AdminPost.find(params[:admin_post_id])
    elsif params[:tag_id]
      @commentable = Tag.find_by_name(params[:tag_id])
      @page_subtitle = @commentable.try(:name)
    end
  end

  def index
    if !@commentable.nil?
      @comments = @commentable.comments.reviewed.page(params[:page])
      if @commentable.class == Comment
        # we link to the parent object at the top
        @commentable = @commentable.ultimate_parent
      end
    else
      if logged_in_as_admin?
        @comments = Comment.top_level.not_deleted.limit(ArchiveConfig.ITEMS_PER_PAGE).ordered_by_date.include_pseud.select { |c| c.ultimate_parent.respond_to?(:visible?) && c.ultimate_parent.visible?(current_user) }
      else
        redirect_back_or_default(root_path)
        flash[:error] = ts("Sorry, you don't have permission to access that page.")
      end
    end
  end

  def unreviewed
    if @commentable.nil?
      flash[:error] = ts("What did you want to review comments on?")
      redirect_back_or_default(root_path)
    else
      @comments = @commentable.find_all_comments.unreviewed_only.page(params[:page])
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comments = [@comment]
    @thread_view = true
    @thread_root = @comment
    params[:comment_id] = params[:id]
  end

  # GET /comments/new
  def new
    if @commentable.nil?
      flash[:error] = ts("What did you want to comment on?")
      redirect_back_or_default(root_path)
    else
      @comment = Comment.new
      @controller_name = params[:controller_name] if params[:controller_name]
      @name =
        case @commentable.class.name
          when /Work/
            @commentable.title
          when /Chapter/
            @commentable.work.title
          when /Tag/
            @commentable.name
          when /AdminPost/
            @commentable.title
          when /Comment/
            ts("Previous Comment")
          else
            @commentable.class.name
        end
    end
  end

  # GET /comments/1/edit
  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /comments
  # POST /comments.xml
  def create
    if @commentable.nil?
      flash[:error] = ts("What did you want to comment on?")
      redirect_back_or_default(root_path)
    else
      @comment = Comment.new(comment_params)
      @comment.ip_address = request.remote_ip
      @comment.user_agent = request.env['HTTP_USER_AGENT']
      @comment.commentable = Comment.commentable_object(@commentable)
      @controller_name = params[:controller_name]

      # First, try saving the comment
      if @comment.save
        if @comment.approved?
          # save user's name/email if not logged in, truncated in case of something really long and wacky
          if @comment.pseud.nil?
            cookies[:comment_name] = @comment.name[0..100]
            cookies[:comment_email] = @comment.email[0..100]
          end
          if @comment.unreviewed?
            flash[:comment_notice] = ts("Your comment was received! It will appear publicly after the work creator has approved it.")
          else
            flash[:comment_notice] = ts('Comment created!')
          end
          respond_to do |format|
            format.html do
              if request.referer&.match(/inbox/)
                redirect_to user_inbox_path(current_user, filters: filter_params[:filters], page: params[:page])
              elsif request.referer&.match(/new/)
                # came here from the new comment page, probably via download link
                # so go back to the comments page instead of reloading full work
                redirect_to comment_path(@comment)
              elsif request.referer == "#{root_url}"
                # replying on the homepage
                redirect_to root_path
              elsif @comment.unreviewed? && current_user
                redirect_to comment_path(@comment)
              elsif @comment.unreviewed?
                redirect_to_all_comments(@commentable)
              else
                redirect_to_comment(@comment, {view_full_work: (params[:view_full_work] == "true"), page: params[:page]})
              end
            end
          end
        else
          # this shouldn't come up any more
          flash[:comment_notice] = ts('Sorry, but this comment looks like spam to us.')
          redirect_back_or_default(root_path)
        end
      else
        flash[:error] = ts("Couldn't save comment!")
        render action: "new"
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    updated_comment_params = comment_params.merge(edited_at: Time.current)
    if @comment.update_attributes(updated_comment_params)
      flash[:comment_notice] = ts('Comment was successfully updated.')
      respond_to do |format|
        format.html do
          redirect_to comment_path(@comment) and return if @comment.unreviewed?
          redirect_to_comment(@comment)
        end
        format.js # updating the comment in place
      end
    else
      render action: "edit"
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    parent = @comment.ultimate_parent
    parent_comment = @comment.reply_comment? ? @comment.commentable : nil
    unreviewed = @comment.unreviewed?

    if !@comment.destroy_or_mark_deleted
      # something went wrong?
      flash[:comment_error] = ts("We couldn't delete that comment.")
      redirect_to_comment(@comment)
    elsif unreviewed
      # go back to the rest of the unreviewed comments
      flash[:notice] = ts("Comment deleted.")
      redirect_back(fallback_location: unreviewed_work_comments_path(@comment.commentable))
    elsif parent_comment
      flash[:comment_notice] = ts("Comment deleted.")
      redirect_to_comment(parent_comment)
    else
      flash[:comment_notice] = ts("Comment deleted.")
      redirect_to_all_comments(parent, {show_comments: true})
    end
  end

  def review
    if @comment && current_user_owns?(@comment.ultimate_parent) && @comment.unreviewed?
      @comment.toggle!(:unreviewed)
      # mark associated inbox comments as read
      InboxComment.where(user_id: current_user.id, feedback_comment_id: @comment.id).update_all(read: true)
      flash[:notice] = ts("Comment approved.")
      respond_to do |format|
        format.html do
          if params[:approved_from] == "inbox"
            redirect_to user_inbox_path(current_user, page: params[:page], filters: filter_params[:filters]) and return
          elsif params[:approved_from] == "home"
            redirect_to root_path and return
          else
            redirect_to unreviewed_work_comments_path(@comment.ultimate_parent) and return
          end
        end
        format.js
      end
    end
  end

  def review_all
    unless @commentable && current_user_owns?(@commentable)
      flash[:error] = ts("What did you want to review comments on?")
      redirect_back_or_default(root_path) and return
    end

    @comments = @commentable.find_all_comments.unreviewed_only
    @comments.each { |c| c.toggle!(:unreviewed) }
    flash[:notice] = ts("All moderated comments approved.")
    redirect_to @commentable and return
  end

  def approve
    @comment.mark_as_ham!
    redirect_to_all_comments(@comment.ultimate_parent, {show_comments: true})
  end

  def reject
   @comment.mark_as_spam!
   redirect_to_all_comments(@comment.ultimate_parent, {show_comments: true})
  end

  def show_comments
    @comments = @commentable.comments.reviewed.page(params[:page])

    respond_to do |format|
      format.html do
        # if non-ajax it could mean sudden javascript failure OR being redirected from login
        # so we're being extra-nice and preserving any intention to comment along with the show comments option
        options = {show_comments: true}
        options[:add_comment] = params[:add_comment] if params[:add_comment]
        options[:add_comment_reply_id] = params[:add_comment_reply_id] if params[:add_comment_reply_id]
        options[:view_full_work] = params[:view_full_work] if params[:view_full_work]
        options[:page] = params[:page]
        redirect_to_all_comments(@commentable, options)
      end
      format.js
    end
  end

  def hide_comments
    respond_to do |format|
      format.html do
        options[:add_comment] = params[:add_comment] if params[:add_comment]
        redirect_to_all_comments(@commentable)
      end
      format.js
    end
  end

  def add_comment
    @comment = Comment.new
    respond_to do |format|
      format.html do
        options = {add_comment: true}
        options[:show_comments] = params[:show_comments] if params[:show_comments]
        options[:page] = params[:page] if params[:page]
        redirect_to_all_comments(@commentable, options)
      end
      format.js
    end
  end

  def add_comment_reply
    @comment = Comment.new
    respond_to do |format|
      format.html do
        options = {show_comments: true}
        options[:controller] = @commentable.class.to_s.underscore.pluralize
        options[:anchor] = "comment_#{params[:id]}"
        options[:page] = params[:page]
        options[:view_full_work] = params[:view_full_work]
        if @thread_view
          options[:id] = @thread_root
          options[:add_comment_reply_id] = params[:id]
          redirect_to_comment(@commentable, options)
        else
          options[:id] = @commentable.id # work, chapter or other stuff that is not a comment
          options[:add_comment_reply_id] = params[:id]
          redirect_to_all_comments(@commentable, options)
        end
      end
      format.js { @commentable = Comment.find(params[:id]) }
    end
  end

  def cancel_comment
    respond_to do |format|
      format.html do
        options = {}
        options[:show_comments] = params[:show_comments] if params[:show_comments]
        redirect_to_all_comments(@commentable, options)
      end
      format.js
    end
  end

  def cancel_comment_reply
    respond_to do |format|
      format.html do
        options = {}
        options[:show_comments] = params[:show_comments] if params[:show_comments]
        redirect_to_all_comments(@commentable, options)
      end
      format.js { @commentable = Comment.find(params[:id]) }
    end
  end

  def cancel_comment_edit
    respond_to do |format|
      format.html { redirect_to_comment(@comment) }
      format.js
    end
  end

  def delete_comment
    respond_to do |format|
      format.html do
        options = {}
        options[:show_comments] = params[:show_comments] if params[:show_comments]
        options[:delete_comment_id] = params[:id] if params[:id]
        redirect_to_comment(@comment, options) # TO DO: deleting without javascript doesn't work and it never has!
      end
      format.js
    end
  end

  def cancel_comment_delete
    respond_to do |format|
      format.html do
        options = {}
        options[:show_comments] = params[:show_comments] if params[:show_comments]
        redirect_to_comment(@comment, options)
      end
      format.js
    end
  end

  protected

  # redirect to a particular comment in a thread, going into the thread
  # if necessary to display it
  def redirect_to_comment(comment, options = {})
    if comment.depth > ArchiveConfig.COMMENT_THREAD_MAX_DEPTH
      if comment.ultimate_parent.is_a?(Tag)
        default_options = {
           controller: :comments,
           action: :show,
           id: comment.commentable.id,
           tag_id: comment.ultimate_parent.to_param,
           anchor: "comment_#{comment.id}"
        }
      else
        default_options = {
           controller: comment.commentable.class.to_s.underscore.pluralize,
           action: :show,
           id: (comment.commentable.is_a?(Tag) ? comment.commentable.to_param : comment.commentable.id),
           anchor: "comment_#{comment.id}"
        }
      end
      # display the comment's direct parent (and its associated thread)
      redirect_to(url_for(default_options.merge(options)))
    else
      # need to redirect to the specific chapter; redirect_to_all will then retrieve full work view if applicable
      redirect_to_all_comments(comment.parent, options.merge({show_comments: true, anchor: "comment_#{comment.id}"}))
    end
  end

  def redirect_to_all_comments(commentable, options = {})
    default_options = {anchor: "comments"}
    options = default_options.merge(options)

    if commentable.is_a?(Tag)
      redirect_to comments_path(tag_id: commentable.to_param,
                  add_comment: options[:add_comment],
                  add_comment_reply_id: options[:add_comment_reply_id],
                  delete_comment_id: options[:delete_comment_id],
                  page: options[:page],
                  anchor: options[:anchor])
    else
      if commentable.is_a?(Chapter) && (options[:view_full_work] || current_user.try(:preference).try(:view_full_works))
        commentable = commentable.work
      end
      redirect_to controller: commentable.class.to_s.underscore.pluralize,
                  action: :show,
                  id: commentable.id,
                  show_comments: options[:show_comments],
                  add_comment: options[:add_comment],
                  add_comment_reply_id: options[:add_comment_reply_id],
                  delete_comment_id: options[:delete_comment_id],
                  view_full_work: options[:view_full_work],
                  anchor: options[:anchor],
                  page: options[:page]
    end
  end

  private

  def comment_params
    params.require(:comment).permit(
      :pseud_id, :content, :name, :email, :edited_at
    )
  end

  def filter_params
    params.permit!
  end
end
