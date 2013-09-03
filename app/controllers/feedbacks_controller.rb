class FeedbacksController < ApplicationController
  skip_before_filter :store_location

  # GET /feedbacks/new
  # GET /feedbacks/new.xml
  def new
    @feedback = Feedback.new
    if logged_in_as_admin?
      @feedback.email = current_admin.email
    elsif is_registered_user?
      @feedback.email = current_user.email
    end
  end

  def create
    @feedback = Feedback.new(params[:feedback])
    respond_to do |format|
      if @feedback.save
        require 'rest_client'
        # Send bug to 16bugs
        if ArchiveConfig.PERFORM_DELIVERIES == true && %w(staging production).include?(Rails.env)
          # For some reason it won't let me move use and password into the config :(
          site = RestClient::Resource.new(ArchiveConfig.BUGS_SITE, :user => ArchiveConfig.BUGS_USER, :password => ArchiveConfig.BUGS_PASSWORD)
          site['/projects/4911/bugs'].post build_post_info(@feedback), :content_type => 'application/xml', :accept => 'application/xml'
        end
        # Email bug to feedback email address
        AdminMailer.feedback(@feedback.id).deliver
        # If user supplies email address, email them an auto-response
        if !@feedback.email.blank?
          UserMailer.feedback(@feedback.id).deliver
        end
        flash[:notice] = t('successfully_sent', :default => 'Your message was sent to the archive team - thank you!')
        format.html { redirect_back_or_default(root_path) }
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
   post_info << "<description><![CDATA[" + strip_html_breaks_simple(feedback.comment) + "]]></description>" unless feedback.comment.blank?
   post_info << "<project-id>4911</project-id>"
   post_info << "<title><![CDATA[" + strip_html_breaks_simple(feedback.summary) + "]]></title>" unless feedback.summary.blank?
   post_info << "<category-id type='integer'><![CDATA[" + feedback.category + "]]></category-id>" unless feedback.category.blank?
   post_info << "<custom-1389><![CDATA[" + feedback.email + "]]></custom-1389>" unless feedback.email.blank?
   post_info << "<custom-1407><![CDATA[" + feedback.user_agent + "]]></custom-1407>" unless feedback.user_agent.blank?
   post_info << "<custom-1573><![CDATA[" + ArchiveConfig.REVISION.to_s + "]]></custom-1573>" unless ArchiveConfig.REVISION.blank?
   post_info << "</bug>"
   return post_info
 end

end
