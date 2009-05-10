class CommentsController < ApplicationController 
  before_filter :load_commentable, :only => [ :index, :new, :create, :edit, :update, 
                                              :show_comments, :hide_comments, :add_comment, 
                                              :cancel_comment, :add_comment_reply, 
                                              :cancel_comment_reply, :cancel_comment_edit,
                                              :delete_comment, :cancel_comment_delete ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :load_comment, :only => [:show, :edit, :update, :delete_comment, :destroy]
  before_filter :check_visibility, :only => [:show]
  before_filter :check_ownership, :only => [:edit, :update]
  before_filter :check_permission_to_edit, :only => [:edit, :update ]
  before_filter :check_permission_to_delete, :only => [:delete_comment, :destroy]
  
  def load_comment
    @comment = Comment.find(params[:id])
    @check_ownership_of = @comment
    @check_visibility_of = @comment
  end
  
  # Must be able to delete other people's comments on owned works, not just owned comments!
  def check_permission_to_delete
    access_denied(:redirect => @comment) unless current_user_owns?(@comment) || current_user_owns?(@comment.ultimate_parent)
  end
  
  
  # Comments cannot be edited after they've been replied to
  def check_permission_to_edit
    unless @comment && @comment.count_all_comments == 0
      flash[:error] = t('edits_disabled', :default => 'Comments with replies cannot be edited')
      redirect_to :back and return
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
    @comments = [@comment]
    @thread_view = true
    @thread_root = @comment
    params[:comment_id] = params[:id]
  end
  
  # GET /comments/new
  def new
    if @commentable.nil?
      flash[:error] = t('no_commentable', :default => "What did you want to comment on?")
     redirect_to :back rescue redirect_to '/'
    else
      @comment = Comment.new
      @controller_name = params[:controller_name] if params[:controller_name]
    end
  end
  
  # GET /comments/1/edit
  def edit
    #@commentable = @comment.commentable # trust me, it's better commented
  end
  
  # POST /comments
  # POST /comments.xml
  def create
    if @commentable.nil?
      flash[:error] = t('no_commentable', :default => "What did you want to comment on?")
     redirect_to :back rescue redirect_to '/'
    else
      @comment = Comment.new(params[:comment])
      @comment.user_agent = request.env['HTTP_USER_AGENT']
      @comment.commentable = Comment.commentable_object(@commentable)
      @controller_name = params[:controller_name]

      # First, try saving the comment
      unless @comment.valid?
        flash[:comment_error] = t('problem_saving', :default => "There was a problem saving your comment:") 
        msg = @comment.errors.full_messages.map {|msg| "<li>#{msg}</li>"}.join
        unless msg.blank?
          flash[:comment_error] += "<ul>#{msg}</ul>"
        end
        redirect_to_all_comments(@commentable) and return
      end
      
      if @comment.set_and_save
        if @comment.approved?
          flash[:comment_notice] = t('comment_created', :default => 'Comment created!')
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
          flash[:comment_notice] = t('spam', :default => 'Sorry, but this comment looks like spam to us.')
         redirect_to :back
        end
      else
        flash[:comment_error] = t('problem_saving', :default => "There was a problem saving your comment.")
       redirect_to :back
      end
    end
  end
  
  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    params[:comment][:edited_at] = Time.current
    if @comment.update_attributes(params[:comment])
      flash[:comment_notice] = t('successfully_updated', :default => 'Comment was successfully updated.')
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
    parent = @comment.ultimate_parent
    parent_comment = @comment.reply_comment? ? @comment.commentable : nil
    
    if !@comment.destroy_or_mark_deleted
      # something went wrong?
      flash[:comment_error] = t('problem_deleting', :default => "We couldn't delete that comment.")
     redirect_to_comment(@comment)
    elsif parent_comment
      flash[:comment_notice] = t('successfully_deleted', :default => "Comment deleted.")
     redirect_to_comment(parent_comment)
    else
      redirect_to_all_comments(parent, {:show_comments => true})
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

## Enigel Feb 09: added redirects for non-ajaxy requests to prevent script barf

  def show_comments
    @comments = @commentable.comments
    
    # if non-ajax it could mean sudden javascript failure OR being redirected from login
    # so we're being extra-nice and preserving any intention to comment along with the show comments option
    if !(request.xml_http_request?)
      options = {:show_comments => true}
      options[:add_comment] = params[:add_comment] if params[:add_comment]
      options[:add_comment_reply_id] = params[:add_comment_reply_id] if params[:add_comment_reply_id]
      redirect_to_all_comments(@commentable, options)
    end
  end

  def hide_comments
    if !(request.xml_http_request?)
      options[:add_comment] = params[:add_comment] if params[:add_comment]
      redirect_to_all_comments(@commentable)
    end        
  end

  def add_comment
    @comment = Comment.new
    
    # if non-ajax it could mean redirection from login, so we're being extra-nice (see above)
    if !(request.xml_http_request?)
      options = {:add_comment => true}
      options[:show_comments] = params[:show_comments] if params[:show_comments]
      redirect_to_all_comments(@commentable, options)
    end
  end
  
  def add_comment_reply
    @comment = Comment.new

    if request.xml_http_request?
      @commentable = Comment.find(params[:id])    
    else
      # again with the being pretty nice
      options = {:show_comments => true}
      options[:controller] = @commentable.class.to_s.downcase.pluralize
      options[:anchor] = "comment#{params[:id]}"
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
  end
  
  def cancel_comment
    if !(request.xml_http_request?)
      options = {}
      options[:show_comments] = params[:show_comments] if params[:show_comments]
      redirect_to_all_comments(@commentable, options)
    end    
  end

  def cancel_comment_reply
    if request.xml_http_request?
      @commentable = Comment.find(params[:id])    
    else
      options = {}
      options[:show_comments] = params[:show_comments] if params[:show_comments]
      redirect_to_all_comments(@commentable, options)
    end    
  end
  
  def cancel_comment_edit
    @comment = Comment.find(params[:id])
    
    if !(request.xml_http_request?)
      redirect_to_comment(@comment)
    end
  end
  
  # ATTENTION: added load_commentable before this
  def delete_comment
    if !(request.xml_http_request?)
      options = {}
      options[:show_comments] = params[:show_comments] if params[:show_comments]
      options[:delete_comment_id] = params[:delete_comment_id] if params[:delete_comment_id]
      redirect_to_comment(@comment, options) # TO DO: deleting without javascript doesn't work and it never has!
    end    
  end
  
  # ATTENTION: added load_commentable before this
  def cancel_comment_delete
    @comment = Comment.find(params[:id])
    
    if !(request.xml_http_request?)
      options = {}
      options[:show_comments] = params[:show_comments] if params[:show_comments]
      redirect_to_comment(@comment, options)
    end    
  end

  protected 

  # redirect to a particular comment in a thread, going into the thread
  # if necessary to display it
  def redirect_to_comment(comment, options = {})
    if comment.depth > ArchiveConfig.COMMENT_THREAD_MAX_DEPTH
      default_options = {:controller => comment.commentable.class.to_s.downcase.pluralize, 
                         :action => :show,
                         :id => comment.commentable.id,
                         :anchor => "comment#{comment.id}"}
      # display the comment's direct parent (and its associated thread)
      redirect_to(url_for(default_options.merge(options)))
    else
      redirect_to_all_comments(comment.ultimate_parent, options.merge({:show_comments => true, :anchor => "comment#{comment.id}"}))
    end
  end

  def redirect_to_all_comments(commentable, options = {})
    default_options = {:anchor => "comments"}
    options = default_options.merge(options)
    redirect_to :controller => commentable.class.to_s.downcase.pluralize,
                :action => :show,
                :id => commentable.id,
                :show_comments => options[:show_comments],
                :add_comment => options[:add_comment],
                :add_comment_reply_id => options[:add_comment_reply_id],
                :delete_comment_id => options[:delete_comment_id],
                :anchor => options[:anchor]
  end
end