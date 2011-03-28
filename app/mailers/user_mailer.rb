class UserMailer < ActionMailer::Base
  include Resque::Mailer # see README in this directory

  helper :application
  helper :tags
  helper :works
  include HtmlCleaner

  default :from => ArchiveConfig.RETURN_ADDRESS

  # Sends an invitation to join the archive
  # Must be sent synchronously as it is rescued
  # TODO refactor to make it asynchronous
  def invitation(invitation)
    @invitation = invitation
    @user_name = (@invitation.creator.is_a?(User) ? @invitation.creator.login : '')
    mail(
      :to => @invitation.invitee_email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Invitation"
    )
  end

  # Sends an invitation to join the archive and claim stories that have been imported as part of a bulk import
  # Must be sent synchronously as it is rescued
  # TODO refactor to make it asynchronous
  def invitation_to_claim(invitation, archivist_login)
    @external_author = invitation.external_author
    @archivist = archivist_login || "An archivist"
    @token = invitation.token
    mail(
      :to => invitation.invitee_email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Invitation To Claim Stories"
    )
  end

  # Notifies a writer that their imported works have been claimed
  def claim_notification(external_author_id, claimed_work_ids)
    external_author = ExternalAuthor.find(external_author_id)
    @external_email = external_author.email
    @claimed_works = Work.find(claimed_work_ids)
    mail(
      :to => external_author.user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Stories Uploaded"
    )
  end

  def subscription_notification(user_id, subscription_id, creation_id, creation_class_name)
    user = User.find(user_id)
    @subscription = Subscription.find(subscription_id)
    @creation = creation_class_name.constantize.find(creation_id)
    if @subscription.subscribable_type == 'User'
      subject_text = "#{@subscription.name} has posted "
      if creation_class_name == 'Chapter'
        subject_text << "Chapter #{@creation.position} of \"#{@creation.work.title}\""
      elsif creation_class_name == 'Work'
        subject_text << "\"#{@creation.title}\""
      end
    else
      subject_text = "Subscription Notice for #{@subscription.name}"
    end
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] #{subject_text}"
    )
  end

  # Emails a user to say they have been given more invitations for their friends
  def invite_increase_notification(user_id, total)
    @user = User.find(user_id)
    @total = total
    mail(
      :to => @user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] New Invitations"
    )
  end

  # Sends an admin message to a user
  def archive_notification(admin_login, user_id, subject, message)
    @user = User.find(user_id)
    @message = message
    @admin_login = admin_login
    mail(
      :to => @user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Admin Message #{subject}"
    )
  end

  # Sends an admin message to an array of users
  def mass_archive_notification(admin, users, subject, message)
    users.each do |user|
      archive_notification(admin, user, subject, message)
    end
  end

  def collection_notification(collection_id, subject, message)
    @message = message
    @collection = Collection.find(collection_id)
    mail(
      :to => @collection.get_maintainers_email,
      :subject => "[#{ArchiveConfig.APP_NAME}][#{@collection.title}] #{subject}"
    )
  end

  def potential_match_generation_notification(collection_id)
    @collection = Collection.find(collection_id)
    mail(
      :to => @collection.get_maintainers_email,
      :subject => "[#{ArchiveConfig.APP_NAME}][#{@collection.title}] Potential Assignment Generation Complete"
    )
  end

  def challenge_assignment_notification(collection_id, assigned_user_id, assignment_id)
    @collection = Collection.find(collection_id)
    @assigned_user = User.find(assigned_user_id)
    assignment = ChallengeAssignment.find(assignment_id)
    @request = (assignment.request_signup || assignment.pinch_request_signup)
    mail(
      :to => @assigned_user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}][#{@collection.title}] Your Assignment!"
    )
  end

  # Asks a user to validate and activate their new account
  def signup_notification(user_id)
    @user = User.find(user_id)
    mail(
      :to => @user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Please activate your new account"
    )
  end

  # Emails a user to confirm that their account is validated and activated
  def activation(user_id)
    @user = User.find(user_id)
    mail(
      :to => @user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Your account has been activated."
    )
  end

  # Sends a temporary password to the user
  def reset_password(user_id)
    @user = User.find(user_id)
    @password = @user.activation_code
    mail(
      :to => @user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Generated password"
    )
  end
	
	  # Confirms to a user that their email was changed
  def change_email(user, old_email, new_email)
    @user = user
		@old_email= old_email
		@new_email= new_email
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Email changed"
    )
  end
   
  ### WORKS NOTIFICATIONS ###

  # Sends email when a user is added as a co-author
  def coauthor_notification(user_id, creation_id, creation_class_name)
    @user = User.find(user_id)
    @creation = creation_class_name.constantize.find(creation_id)
    mail(
      :to => @user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Co-Author Notification"
    )
  end

  # Sends emails to authors whose stories were listed as the inspiration of another work
  def related_work_notification(user_id, related_work_id)
    @user = User.find(user_id)
    @related_work = RelatedWork.find(related_work_id)
    @related_parent_link = url_for(:controller => :works, :action => :show, :id => @related_work.parent)
    @related_child_link = url_for(:controller => :works, :action => :show, :id => @related_work.work)
    mail(
      :to => @user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Related work notification"
    )
  end

  # Emails a recipient to say that a gift has been posted for them
  def recipient_notification(user_id, work_id, collection_id=nil)
    user = User.find(user_id)
    @work = Work.find(work_id)
    @collection = Collection.find(collection_id) if collection_id
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}]#{@collection ? '[' + @collection.title + ']' : ''} A Gift Story For You #{@collection ? 'From ' + @collection.title : ''}"
    )
  end

  # Emails a prompter to say that a response has been posted to their prompt
  def prompter_notification(user_id, work_id, collection_id=nil)
    user = User.find(user_id)
    @work = Work.find(work_id)
    @collection = Collection.find(collection_id) if collection_id
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] A Response to your Prompt"
    )
  end

  # Sends email to coauthors when a work is edited
  # NOTE: this must be sent synchronously! otherwise the new version will be sent.
  # TODO refactor to make it asynchronous by passing the content in the method
  def edit_work_notification(user, work)
    @user = user
    @work = work
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Your story has been updated"
    )
  end

  # Sends email to authors when a creation is deleted
  # NOTE: this must be sent synchronously! otherwise the work will no longer be there to send
  # TODO refactor to make it asynchronous by passing the content in the method
  def delete_work_notification(user, work)
    @user = user
    @work = work
    work_copy = generate_attachment_content_from_work(work)
    filename = work.title.gsub(/[*:?<>|\/\\\"]/,'')
    attachments["#{filename}.txt"] = {:content => work_copy}
    attachments["#{filename}.html"] = {:content => work_copy}

    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Your story has been deleted"
    )
  end

  ### OTHER NOTIFICATIONS ###

  # archive feedback
  def feedback(feedback_id)
    feedback = Feedback.find(feedback_id)
    return unless feedback.email
    @summary = feedback.summary
    @comment = feedback.comment
    mail(
      :to => feedback.email,
      :subject => "#{ArchiveConfig.APP_NAME}: Support - #{strip_html_breaks_simple(feedback.summary)}"
    )
  end

  def abuse_report(report_id)
    report = AbuseReport.find(report_id)
    setup_email_without_name(report.email)
    @url = report.url
    @comment = report.comment
    mail(
      :to => report.email,
      :subject => "[#{ArchiveConfig.APP_NAME}] Your abuse report"
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

end
