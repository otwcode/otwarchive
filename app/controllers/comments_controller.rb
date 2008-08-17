class CommentsController < ApplicationController 
  before_filter :load_commentable, :only => [ :index, :new, :create, :edit, :update, :showcomments ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
  before_filter :check_permission_to_view, :only => [:show]
  before_filter :check_permission_to_edit, :only => [:edit, :update]
  
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
    unless current_user.is_a?(User) && current_user.is_author_of?(@comment)
      flash[:error] = "Sorry, but you don't have permission to make edits.".t
      redirect_to(@work)     
    end
    unless @comment.count_all_comments == 0
      flash[:error] = 'Comments with replies cannot be edited'.t
      redirect_to :back
    end  
  end
    
  # Get the parent of the desired comment(s) 
  # Just covering all the bases here for now
  def load_commentable
    if params[:comment_id]
      @commentable = Comment.find(params[:comment_id])
    elsif params[:chapter_id]
      @commentable = Chapter.find(params[:chapter_id])
    elsif params[:work_id]
      @commentable = Work.find(params[:work_id]).last_chapter
    elsif params[:user_id]
      @commentable = User.find_by_login(params[:user_id])
    elsif params[:pseud_id]
      @commentable = Pseud.find(params[:pseud_id])
    end    
  end
  
  # GET /comments
  def index 
    @comments = @commentable.nil? ? Comment.find(:all) : @commentable.find_all_comments
  end
  
  # GET /comments/1
  # GET /comments/1.xml
  def show
    comment = Comment.find(params[:id])
    @comments = comment.full_set
  end
  
  # GET /comments/new
  def new
    if @commentable.nil?
      flash[:error] = "What did you want to comment on?".t
      redirect_to :back
    else
      if @commentable.kind_of?(Work)
        @commentable = @commentable.last_chapter
      end
      @comment = Comment.new
      respond_to do |format|
        format.html
        format.js
      end
    end
  end
  
  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  # POST /comments
  # POST /comments.xml
  def create
    if @commentable.nil?
      flash[:error] = "What did you want to comment on?".t
      redirect_to :back
    else
      @comment = Comment.new(params[:comment])
      @comment.update_attribute(:user_agent,request.env['HTTP_USER_AGENT'])
      
      if @comment.set_and_save
        if @comment.approved?
          flash[:notice] = 'Comment was successfully created.'.t
          parent = @comment.ultimate_parent
          @comments = @comment.commentable.find_all_comments
          respond_to do |format|
              format.html { redirect_to :controller => parent.class.to_s.pluralize, :action => 'show', :id => parent.id, :anchor => "comment#{@comment.id}" }
              format.js
            end
        else
          flash[:notice] = 'Comment was marked as spam by Akismet.'.t
          redirect_to :back
        end
      else
        render :action => "new", :locals => {:commentable => @comment.commentable, :button_name => 'Create'.t}
      end
    end
  end
  
  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])
    
    if @comment.update_attributes(params[:comment])
      flash[:notice] = 'Comment was successfully updated.'.t
      parent = @comment.ultimate_parent
      respond_to do |format|
          format.html { redirect_to :controller => parent.class.to_s.pluralize, :action => 'show', :id => parent.id, :anchor => "comment#{@comment.id}" }
          format.js
        end
    else
      render :action => "edit" 
    end
  end
  
  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy_or_mark_deleted
    redirect_to(@comment.commentable)
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
   redirect_to(@comment.ultimate_parent)
  end

 # Shows comments for JS users if they click the 'show comments' link
  def showcomments
   # if comments are on a work
   if params[:work_id]
     @work = Work.find(params[:work_id])
     @comments = @work.find_all_comments
     respond_to do |format|
       format.js
     end
   # if comments are on a chapter  
   elsif params[:chapter_id]
     @chapter = Chapter.find(params[:chapter_id])
     @comments = @chapter.find_all_comments
     respond_to do |format|
       format.js
     end
   end
  end  
  
end
