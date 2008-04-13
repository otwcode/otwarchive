class CommentsController < ApplicationController
  # GET /comments
  # GET /comments.xml
  def index 
    @work = Work.find(:first)
    @comments = @work.find_all_comments

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])
    @comments = @comment.all_children

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
    if logged_in?
      @comment.pseud_id = current_user.active_pseud.id
    end
    @comment.set_depth
    if @comment.reply_comment?
      @old_comment = Comment.find(@comment.commentable_id)
      @comment.thread = @old_comment.thread
      @old_comment.add_child(@comment)

      # Disabling email for now but leaving this here as a placeholder
      # if @old_comment.pseud_id
         # @recipient = User.find(@old_comment.pseud.user_id)
         # UserMailer.deliver_send_comments(@recipient, @comment)
      # end
      
    else
      if Comment.max_thread
        @comment.thread = Comment.max_thread.to_i + 1
      else
        @comment.thread = 1
      end
    end

    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Comment was successfully created.'
        format.html { redirect_to(@comment) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :action => "new", :locals => {:commentable => @comment.commentable, :button_name => 'Create'} }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(@comment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    if @comment.children_count > 0 
      @comment.is_deleted = true
      @comment.save
    else
      @comment.destroy
    end

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
end
