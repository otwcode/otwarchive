class CommentsController < ApplicationController 
  before_filter :load_commentable, :only => [ :index, :new, :create, :edit, :update, 
                                              :show_comments, :hide_comments, :add_comment, 
                                              :cancel_comment, :add_comment_reply, 
                                              :cancel_comment_reply, :cancel_comment_edit ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_permission_to_view, :only => [:show]
  before_filter :check_permission_to_edit, :only => [:edit, :update ]
  before_filter :check_permission_to_delete, :only => [:delete_comment, :destroy]
  
  # Make sure hidden comments aren't publically visible
  def check_permission_to_view
    @comment = Comment.find(params[:id])
    if @comment.hidden_by_admin?
      access_denied if !logged_in_as_admin? || !(logged_in? && current_user.is_author_of?(@comment))
    end
  end
  
  # Comments cannot be edited after they've been replied to
  def check_permission_to_edit
    @comment = Comment.find(params[:id])
    unless @comment && logged_in? && current_user.is_a?(User) && current_user.is_author_of?(@comment)
      flash[:error] = "Sorry, but you don't have permission to make edits.".t
      redirect_to :back and return
    end
    unless @comment && @comment.count_all_comments == 0
      flash[:error] = 'Comments with replies cannot be edited'.t
      redirect_to :back and return
    end  
  end

  def check_permission_to_delete
    @comment = Comment.find(params[:id])
    unless (@comment && logged_in? && (current_user.is_author_of?(@comment) || current_user.is_author_of?(@comment.ultimate_parent)))
      flash[:error] = "Sorry, but you don't have permission to delete this comment.".t
      redirect_to :back and return
    end
  end
    
  # Get the thing the user is trying to comment on
  def load_commentable
    if params[:comment_id]
      @commentable = Comment.find(params[:comment_id])
    elsif params[:chapter_id]
      @commentable = Chapter.find(params[:chapter_id])
    elsif params[:work_id]
      @commentable =  Work.find(params[:work_id])
    elsif params[:bookmark_id]
      @commentable = Bookmark.find(params[:bookmark_id])
    end    
  end

  def index
    if @commentable.nil?
      @comments = Comment.recent
    else
      @comments = @commentable.comments
      if @commentable.class == Comment
        # we link to the parent object at the top
        @commentable = @commentable.ultimate_parent
      end
    end
    
  end
  
  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])
    @comments = [@comment]
  end
  
  # GET /comments/new
  def new
    if @commentable.nil?
      flash[:error] = "What did you want to comment on?".t
      redirect_to :back
    else
      @comment = Comment.new
      @controller_name = params[:controller_name] if params[:controller_name]
    end
  end
  
  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
    @commentable = @comment.commentable
  end
  
  # POST /comments
  # POST /comments.xml
  def create
    if @commentable.nil?
      flash[:error] = "What did you want to comment on?".t
      redirect_to :back
    else
      @comment = Comment.new(params[:comment])
      @comment.user_agent = request.env['HTTP_USER_AGENT']
      @comment.commentable = Comment.commentable_object(@commentable)
      @controller_name = params[:controller_name]

      # First, try saving the comment
      unless @comment.valid?
        flash[:comment_error] = "There was a problem saving your comment:".t 
        msg = @comment.errors.full_messages.map {|msg| "<li>#{msg}</li>"}.join
        unless msg.blank?
          flash[:comment_error] += "<ul>#{msg}</ul>"
        end
        redirect_to_all_comments(@commentable) and return
      end
      
      if @comment.set_and_save
        if @comment.approved?
          flash[:comment_notice] = 'Comment created!'.t
          respond_to do |format|
            format.html do 
              if request.env['HTTP_REFERER'] =~ /inbox/
                redirect_to user_inbox_path(current_user)
              else
                redirect_to_comment(@comment)
              end
            end
          end 
        else
          # this shouldn't come up any more
          flash[:comment_notice] = 'Sorry, but this comment looks like spam to us.'.t
          redirect_to :back
        end
      else
        flash[:comment_error] = "There was a problem saving your comment.".t
        redirect_to :back
      end
    end
  end
  
  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])    
    if @comment.update_attributes(params[:comment])
      flash[:comment_notice] = 'Comment was successfully updated.'.t
      respond_to do |format|
        format.html { redirect_to_comment(@comment) }
      end
    else
      render :action => "edit" 
    end
  end
  
  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])    
    parent = @comment.ultimate_parent
    parent_comment = @comment.reply_comment? ? @comment.commentable : nil
    
    if !@comment.destroy_or_mark_deleted
      # something went wrong?
      flash[:comment_error] = "We couldn't delete that comment.".t
      redirect_to_comment(@comment)
    elsif parent_comment
      flash[:comment_notice] = "Comment deleted.".t
      redirect_to_comment(parent_comment)
    else
      redirect_to_all_comments(parent)
    end
  end

  def approve
    @comment = Comment.find(params[:id])
    @comment.mark_as_ham!
    redirect_to(comments_url)
  end

  def reject
   @comment = Comment.find(params[:id])
   @comment.mark_as_spam!
   # Needs better redirect
   redirect_to_comments(@comment.ultimate_parent)
  end

  def show_comments
    @comments = @commentable.comments
  end

  def hide_comments
    
  end

  def add_comment
    @comment = Comment.new
  end
  
  def add_comment_reply
    @comment = Comment.new
  end
  
  def cancel_comment
    
  end

  def cancel_comment_reply
    
  end
  
  def cancel_comment_edit
    @comment = Comment.find(params[:id])
  end
  
  def delete_comment
    @comment = Comment.find(params[:id])
  end
  
  def cancel_comment_delete
    @comment = Comment.find(params[:id])
  end

  protected 
    # redirect to a particular comment in a thread, going into the thread
    # if necessary to display it
    def redirect_to_comment(comment)
      if comment.depth > ArchiveConfig.COMMENT_THREAD_MAX_DEPTH
        # display the comment's direct parent (and its associated thread)
        redirect_to comment.commentable
      else
        redirect_to_all_comments(comment.ultimate_parent, :anchor => "comment_#{comment.id}")
      end
    end

    def redirect_to_all_comments(commentable, options = {})
      default_options = {:anchor => 'comments'}
      options = default_options.merge(options)
      redirect_to :controller => commentable.class.to_s.downcase.pluralize,
                  :action => :show,
                  :id => commentable.id,
                  :show_comments => true,
                  :anchor => options[:anchor]
    end
          
    
end
