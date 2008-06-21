class CommentsController < ApplicationController 
  before_filter :load_commentable, :only => [ :index, :new, :create, :edit, :update, :showcomments ]
  
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
    elsif @commentable.kind_of?(Work)
      @commentable = @commentable.last_chapter
    end
    @comment = Comment.new
  end
  
  
  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
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
   redirect_to(comments_url)
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
