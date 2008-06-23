class FeedbacksController < ApplicationController
  
  # GET /feedbacks/new
  # GET /feedbacks/new.xml
  def new
    @feedback = Feedback.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedback }
    end
  end
  
  
  def create
    @feedback = Feedback.new(params[:feedback])
    
    respond_to do |format|
      if @feedback.save
        AdminMailer.deliver_feedback(@feedback.comment)
        flash[:notice] = 'Your feedback was sent to the archive team - thanks for your input!'
        format.html { redirect_to :controller => 'session', :action => 'new' }
      
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /feedbacks/1
  # PUT /feedbacks/1.xml
  def update
    @feedback = Feedback.find(params[:id])
    
    respond_to do |format|
      if @feedback.update_attributes(params[:feedback])
        flash[:notice] = 'Feedback was successfully updated.'
        format.html { redirect_to(@feedback) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end