class FeedbacksController < ApplicationController
  
  # GET /feedbacks/new
  # GET /feedbacks/new.xml
  def new
    @feedback = Feedback.new
     unless User.current_user == :false
      @feedback.email = User.current_user.email
    else
      @feedback.email = ""
    end
	
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  
  def create
    @feedback = Feedback.new(params[:feedback])
    
    respond_to do |format|
      if @feedback.save
        AdminMailer.deliver_feedback(@feedback)
        flash[:notice] = t('notices.feedbacks.successfully_sent', :default => 'Your feedback was sent to the archive team - thanks for your input!')
       format.html { redirect_to '' }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
 
  
end