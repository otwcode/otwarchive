class FeedbacksController < ApplicationController
  
  # GET /feedbacks/new
  # GET /feedbacks/new.xml
  def new
    @feedback = Feedback.new
    @page_title = "Support and Feedback"
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
        require 'rest_client'
        # Send bug to 16bugs
        if ArchiveConfig.PERFORM_DELIVERIES == true
          # For some reason it won't let me move use and password into the config :(
          site = RestClient::Resource.new(ArchiveConfig.BUGS_SITE, :user => 'otwadmin', :password => '11egbiaon6bockky1l5b5fkts6i1sbsshhsqywxb8t4bq9v918')
          site['/projects/4911/bugs'].post build_post_info(@feedback), :content_type => 'application/xml', :accept => 'application/xml'
        end
        # Email bug to feedback email address
        AdminMailer.deliver_feedback(@feedback)
        # If user supplies email address, email them an auto-response
        if !@feedback.email.blank?
          UserMailer.deliver_feedback(@feedback)
        end
        flash[:notice] = t('successfully_sent', :default => 'Your message was sent to the archive team - thank you!')
        format.html { redirect_to '' }
      else
        flash[:error] = t('failure_send', :default => 'Sorry, your message could not be saved - please try again!')
        format.html { render :action => "new" }
      end
    end
  end


 protected
 
 def build_post_info(feedback)
   post_info = ""
   post_info << "<bug>"
   post_info << "<description><![CDATA[" + feedback.comment + "]]></description>" unless feedback.comment.blank?
   post_info << "<project-id>4911</project-id>"
   post_info << "<title><![CDATA[" + feedback.summary + "]]></title>" unless feedback.summary.blank?
   post_info << "<category-id type='integer'><![CDATA[" + feedback.category + "]]></category-id>" unless feedback.category.blank?
   post_info << "<custom-1389><![CDATA[" + feedback.email + "]]></custom-1389>" unless feedback.email.blank?
   post_info << "<custom-1407><![CDATA[" + feedback.user_agent + "]]></custom-1407>" unless feedback.user_agent.blank?
   post_info << "<version-id type='integer' nil='true'>3910</version-id>"
   post_info << "</bug>"
   return post_info
 end
 
end