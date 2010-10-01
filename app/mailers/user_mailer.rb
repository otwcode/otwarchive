class UserMailer < ActionMailer::Base

  default :from => ArchiveConfig.RETURN_ADDRESS
  
  # Sends an invitation to join the archive
  def invitation(invitation)
    @invitation = invitation
    @user_name = (invitation.creator.is_a?(User) ? invitation.creator.login : '')
    mail(
      :to => invitation.invitee_email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Invitation"
    )
  end
  
  # Sends an invitation to join the archive and claim stories that have been imported as part of a bulk import
  def invitation_to_claim(invitation, archivist)
    @external_author = invitation.external_author
    @archivist = archivist || "An archivist"
    @token = invitation.token
    mail(
      :to => invitation.invitee_email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Invitation To Claim Stories"
    )
  end
  
  # Notifies a writer that their imported works have been claimed
  def claim_notification(external_author, claimed_works)
    @email = external_author.email
    @claimed_works = claimed_works
    mail(
      :to => external_author.user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Stories Uploaded"
    )
  end

  # Emails a recipient to say that a gift has been posted for them
  def recipient_notification(user, work, collection=nil)
    @work = work
    @collection = collection
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}]#{collection ? '[' + collection.title + ']' : ''} A Gift Story For You #{collection ? 'From ' + collection.title : ''}"
    )
  end

  # Emails a user to say they have been given more invitations for their friends
  def invite_increase_notification(user, total)
    @user = @user
    @total = total 
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] New Invitations"
    )
  end

  # Sends an admin message to a user
  def archive_notification(admin, user, subject, message)
    @message = message
    @admin = admin
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Admin Message #{subject}"
    )
  end
  
  def collection_notification(collection, subject, message)
    @message = message
    @collection = collection
    mail(
      :to => collection.get_maintainers_email,
      :subject => "[#{ArchiveConfig.APP_NAME}][#{collection.title}] #{subject}"
    )
  end

  def potential_match_generation_notification(collection)
    @collection = collection
    mail(
      :to => collection.get_maintainers_email,
      :subject => "[#{ArchiveConfig.APP_NAME}][#{collection.title}] Potential Match Generation Complete"
    )
  end

  def challenge_assignment_notification(collection, assigned_user, assignment)
    @collection = collection
    @assigned_user = assigned_user
    @request = (assignment.request_signup || assignment.pinch_request_signup)
    mail(
      :to => assigned_user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}][#{collection.title}] Your Assignment!"
    )
  end

  # Asks a user to validate and activate their new account
  def signup_notification(user)
    @user = user
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Please activate your new account"
    )
  end
   
  # Emails a user to confirm that their account is validated and activated
  def activation(user)
    @user = user
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Your account has been activated."
    )
  end 
  
  # Confirms to a user that their password was reset
  def reset_password(user)
    @user = user
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Password reset"
    )
  end
   
  ### COMMENT NOTIFICATIONS ###
  
  # Sends email to an owner of the top-level commentable when a new comment is created
  def comment_notification(user, comment)
    @comment = comment
    setup_comment_links(comment)
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] " + comment.ultimate_parent.commentable_name
    )
  end

  # Sends email to an owner of the top-level commentable when a comment is edited
  def edited_comment_notification(user, comment)
    setup_email(user)
    @body[:commentable] = comment.ultimate_parent     
    @body[:comment] = comment
    setup_comment_links(comment)
    @subject += "Edited comment on " + comment.ultimate_parent.commentable_name
  end

  # Sends email to comment creator when a reply is posted to their comment
  # This may be a non-user of the archive
  def comment_reply_notification(old_comment, new_comment)
    setup_comment_email(old_comment)
    setup_comment_links(new_comment)
    @subject += "Reply to your comment on " + old_comment.ultimate_parent.commentable_name     
    @body[:comment] = new_comment
  end
   
  # Sends email to comment creator when a reply to their comment is edited
  # This may be a non-user of the archive
  def edited_comment_reply_notification(old_comment, edited_comment)
    setup_comment_email(old_comment)
    setup_comment_links(edited_comment)
    @subject += "Edited reply to your comment on " + old_comment.ultimate_parent.commentable_name     
    @body[:comment] = edited_comment
  end

   # Sends email to the poster of a comment 
  def comment_sent_notification(comment)
    setup_comment_email(comment)
    setup_comment_links(comment)
    @subject += "Comment you sent on " + comment.ultimate_parent.commentable_name
    @body[:reply_to_link] = nil # don't give reply link to your own comment
    @body[:comment] = comment
  end
   
  ### WORKS NOTIFICATIONS ###
  
  # Sends email when a user is added as a co-author
  def coauthor_notification(user, creation)
    setup_email(user)
    @body[:creation] = creation
    @subject += "Co-Author Notification"
  end 
   
  # Sends emails to authors whose stories were listed as the inspiration of another work
  def related_work_notification(user, related_work)
    setup_email(user)
    setup_related_links(related_work)
    @subject    += "Related work notification"
    @body[:related_work] = related_work
  end
   
  # Sends email to authors when a work is edited
  def edit_work_notification(user, work)
    setup_email(user)
    @subject    += "Your story has been updated"
    @body[:work] = work
  end
   
  # Sends email to authors when a creation is deleted
  def delete_work_notification(user, work)
    setup_email(user)
    @content_type = "multipart/mixed"
    @subject    += "Your story has been deleted"
    @body[:work] = work

    part :content_type => "text/html", :body => render_message("delete_work_notification.html", :work => work)  
    
    work_copy = generate_attachment_from_work(work)
    part :content_type => "multipart/mixed" do |p|
      p.attachment :content_type => "text/plain", :filename => work.title.gsub(/[*:?<>|\/\\\"]/,'') + ".txt", :body => work_copy
      p.attachment :content_type => "text/plain", :filename => work.title.gsub(/[*:?<>|\/\\\"]/,'') + ".html", :body => work_copy
    end
  end
  
  # archive feedback
  def feedback(feedback)
    setup_email_without_name(feedback.email)
    @subject = "#{ArchiveConfig.APP_NAME}: Support - " + feedback.summary
    @body[:summary] = feedback.summary
    @body[:comment] = feedback.comment
  end  

  def abuse_report(report)
     setup_email_without_name(report.email)
     @recipients = report.email
     @subject += "Your abuse report"
     @body = {:url => report.url, :comment => report.comment}
  end

  def generate_attachment_from_work(work)
    attachment_string =  "Title: " + work.title + "<br />" + "by " + work.pseuds.collect(&:name).join(", ") + "<br />\n"
    attachment_string += "<br/>Tags: " + work.tags.collect(&:name).join(", ") + "<br/>\n" unless work.tags.blank?
    attachment_string += "<br/>Summary: " + work.summary + "<br/>\n" unless work.summary.blank?
    attachment_string += "<br/>Notes: " + work.notes + "<br/>\n" unless work.notes.blank?
    attachment_string += "<br/>End Notes: " + work.endnotes + "<br/>\n" unless work.endnotes.blank?
    attachment_string += "<br/>Published at: " + work.first_chapter.published_at.to_s + "<br/>\n" unless work.first_chapter.published_at.blank?
    attachment_string += "Revised at: " + work.revised_at.to_s + "<br/>\n" unless work.revised_at.blank?

    work.chapters.each do |chapter|
      attachment_string += "<br/>Chapter " + chapter.position.to_s unless !work.chaptered?
      attachment_string += ": " + chapter.title unless chapter.title.blank?
      attachment_string += "\n<br/>by: " + chapter.pseuds.collect(&:name).join(", ") + "<br />\n" unless chapter.pseuds.sort == work.pseuds.sort
      attachment_string += "<br/>Summary: " + chapter.summary + "<br/>\n" unless chapter.summary.blank?
      attachment_string += "<br/>Notes: " + chapter.notes + "<br/>\n" unless chapter.notes.blank?
      attachment_string += "<br/>End Notes: " + chapter.endnotes + "<br/>\n" unless chapter.endnotes.blank?
      attachment_string += "<br/>" + chapter.content + "<br />\n"
    end
    return attachment_string
  end
  
  protected
   
    def setup_email(user)
      setup_email_attributes
      @recipients  = "#{user.email}"
      @body[:user] = user
      @body[:name] = user.login
    end
     
    def setup_email_to_nonuser(email, name)
      setup_email_attributes
      @recipients = email
      @body[:name] = name
    end
    
    def setup_email_without_name(email)
      setup_email_attributes
      @recipients = email     
    end
     
    def setup_email_attributes
      @from        = ArchiveConfig.RETURN_ADDRESS
      @subject     = "[#{ArchiveConfig.APP_NAME}] "
      @sent_on     = Time.now
      @body[:url]  = ArchiveConfig.APP_URL
      @body[:host] = ArchiveConfig.APP_URL.gsub(/http:\/\//, '')
      @content_type = "text/html"
    end
     
    def setup_comment_email(comment)
      setup_email_to_nonuser(comment.comment_owner_email, comment.comment_owner_name)
      @body[:commentable] = comment.ultimate_parent
    end
    
    def setup_comment_links(comment)
      @commentable = comment.ultimate_parent     
      @reply_to_link = url_for(:host => @body[:host], :controller => comment.class.to_s.underscore.pluralize, 
                                :action => :show, :id => comment, 
                                :add_comment_reply_id => comment.id, :show_comments => true, :anchor => "comment_#{comment.id}")
      @starting_thread_link = url_for(:host => @body[:host], :controller => comment.class.to_s.underscore.pluralize, 
                                :action => :show, :id => comment)
      @originating_thread_link = url_for(:host => @body[:host], :controller => comment.class.to_s.underscore.pluralize, 
                                :action => :show, :id => comment.thread)
    end
    
    def setup_related_links(related_work)
      @body[:related_work] = related_work
      @body[:related_parent_link] = url_for(:host => @body[:host], :controller => :works, :action => :show, :id => @body[:related_work].parent)
      @body[:related_child_link] = url_for(:host => @body[:host], :controller => :works, :action => :show, :id => @body[:related_work].work)
    end
    
end
