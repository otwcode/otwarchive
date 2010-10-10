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
    setup_email_to_user(user)
    setup_comment_links(comment)
    mail(
      :to => user.email,
      :subject => @subject + "Comment on " + comment.ultimate_parent.commentable_name
    )
  end

  # Sends email to an owner of the top-level commentable when a comment is edited
  def edited_comment_notification(user, comment)
    setup_email_to_user(user)
    setup_comment_links(comment)
    mail(
      :to => user.email,
      :subject => @subject + "Edited comment on " + comment.ultimate_parent.commentable_name
    )
  end

  # Sends email to comment creator when a reply is posted to their comment
  # This may be a non-user of the archive
  def comment_reply_notification(old_comment, new_comment)
    setup_comment_email(old_comment)
    setup_comment_links(new_comment)
    mail(
      :to => user.email,
      :subject => @subject + "Reply to your comment on " + old_comment.ultimate_parent.commentable_name
    )
  end
   
  # Sends email to comment creator when a reply to their comment is edited
  # This may be a non-user of the archive
  def edited_comment_reply_notification(old_comment, edited_comment)
    setup_comment_email(old_comment)
    setup_comment_links(edited_comment)
    mail(
      :to => user.email,
      :subject => @subject + "Edited reply to your comment on " + old_comment.ultimate_parent.commentable_name     
    )
  end

   # Sends email to the poster of a comment 
  def comment_sent_notification(comment)
    setup_comment_email(comment)
    setup_comment_links(comment)
    @subject + "Comment you sent on " + comment.ultimate_parent.commentable_name
    @reply_to_link = nil # don't give reply link to your own comment
    mail(
      :to => user.email,
      :subject => @subject + "Comment you sent on " + comment.ultimate_parent.commentable_name
    )
  end
   
  ### WORKS NOTIFICATIONS ###
  
  # Sends email when a user is added as a co-author
  def coauthor_notification(user, creation)
    setup_email_to_user(user)
    @creation = creation
    mail(
      :to => user.email,
      :subject => @subject + "Co-Author Notification"
    )
  end 
   
  # Sends emails to authors whose stories were listed as the inspiration of another work
  def related_work_notification(user, related_work)
    setup_email_to_user(user)
    @related_work = related_work
    @related_parent_link = url_for(:host => @host, :controller => :works, :action => :show, :id => @related_work.parent)
    @related_child_link = url_for(:host => @host, :controller => :works, :action => :show, :id => @related_work.work)
    mail(
      :to => user.email,
      :subject => @subject + "Related work notification"
    )
  end
   
  # Sends email to coauthors when a work is edited
  def edit_work_notification(user, work)
    setup_email_to_user(user)
    @work = work
    mail(
      :to => user.email,
      :subject => @subject + "Your story has been updated"
    )
  end
   
  # Sends email to authors when a creation is deleted
  def delete_work_notification(user, work)
    setup_email_to_user(user)
    @subject    += "Your story has been deleted"
    @work = work
    work_copy = generate_attachment_content_from_work(work)
    filename = work.title.gsub(/[*:?<>|\/\\\"]/,'')
    attachments["#{filename}.txt"] = {:content => work_copy}
    attachments["#{filename}.html"] = {:content => work_copy}

    mail(
      :to => user.email,
      :subject => @subject + "Your story has been deleted"
    )
  end
  
  # archive feedback
  def feedback(feedback)
    setup_email_without_name(feedback.email)
    @summary = feedback.summary
    @comment = feedback.comment
    mail(
      :to => user.email,
      :subject => "#{ArchiveConfig.APP_NAME}: Support - " + feedback.summary
    )
  end  

  def abuse_report(report)
    setup_email_without_name(report.email)
    @recipients = report.email
    @url = report.url
    @comment = report.comment
    mail(
      :to => @recipients,
      :subject => @subject + "Your abuse report"
    )
  end

  def generate_attachment_content_from_work(work)
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

    def setup_email_attributes
      @subject     = "[#{ArchiveConfig.APP_NAME}] "
      @sent_on     = Time.now
      @url  = ArchiveConfig.APP_URL
      @host = ArchiveConfig.APP_URL.gsub(/http:\/\//, '')
      @content_type = "text/html"
    end
   
    def setup_email_to_users(users)
      setup_email_attributes
      @recipients = users.collect {|user| user.email}.join(', ')
    end
   
    def setup_email_to_user(user)
      setup_email_attributes
      @recipients  = "#{user.email}"
      @user = user
      @name = user.login
    end
     
    def setup_email_to_nonuser(email, name)
      setup_email_attributes
      @recipients = email
      @name = name
    end
    
    def setup_email_without_name(email)
      setup_email_attributes
      @recipients = email     
    end
     
    def setup_comment_email(comment)
      @commentable = comment.ultimate_parent
    end
    
    def setup_comment_links(comment)
      @comment = comment
      @commentable = comment.ultimate_parent     
      @comment_owner_link_or_name = comment.comment_owner ? link_to(comment.comment_owner_name, user_url(comment.comment_owner)) : comment.comment_owner_name 
      @reply_to_link = url_for(:host => @host, :controller => comment.class.to_s.underscore.pluralize, 
                                :action => :show, :id => comment, 
                                :add_comment_reply_id => comment.id, :show_comments => true, :anchor => "comment_#{comment.id}")
      @starting_thread_link = url_for(:host => @host, :controller => comment.class.to_s.underscore.pluralize, 
                                :action => :show, :id => comment)
      @originating_thread_link = url_for(:host => @host, :controller => comment.class.to_s.underscore.pluralize, 
                                :action => :show, :id => comment.thread)
    end
    
end
