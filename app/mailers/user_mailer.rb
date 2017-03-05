class UserMailer < BulletproofMailer::Base
  include Resque::Mailer # see README in this directory

  layout 'mailer'

  include AuthlogicHelpersForMailers # otherwise any logged_in? checks in views will choke and die! :)
  helper_method :current_user
  helper_method :current_admin
  helper_method :logged_in?
  helper_method :logged_in_as_admin?

  helper :application
  helper :mailer
  helper :tags
  helper :works
  helper :users
  helper :date
  helper :series
  include HtmlCleaner

  default from: "Archive of Our Own " + "<#{ArchiveConfig.RETURN_ADDRESS}>"

  # Send an email letting authors know their work has been added to a collection
  def added_to_collection_notification(user_id, work_id, collection_id)
    @user = User.find(user_id)
    @work = Work.find(work_id)
    @collection = Collection.find(collection_id)
    mail(
         to: @user.email,
         subject: "[#{ArchiveConfig.APP_SHORT_NAME}]#{'[' + @collection.title + ']'} Your work was added to a collection"
    )
  end

  # Send a request to a work owner asking that they approve the inclusion
  # of their work in a collection
  def invited_to_collection_notification(user_id, work_id, collection_id)
    @user = User.find(user_id)
    @work = Work.find(work_id)
    @collection = Collection.find(collection_id)
    mail(
         to: @user.email,
         subject: "[#{ArchiveConfig.APP_SHORT_NAME}]#{'[' + @collection.title + ']'} Request to include work in a collection"
    )
  end

  # Sends an invitation to join the archive
  # Must be sent synchronously as it is rescued
  # TODO refactor to make it asynchronous
  def invitation(invitation_id)
    @invitation = Invitation.find(invitation_id)
    @user_name = (@invitation.creator.is_a?(User) ? @invitation.creator.login : '')
    mail(
      to: @invitation.invitee_email,
      subject: t(".invitation.subject", app_name: ArchiveConfig.APP_SHORT_NAME)
    )
  end

  # Sends an invitation to join the archive and claim stories that have been imported as part of a bulk import
  def invitation_to_claim(invitation_id, archivist_login)
    @invitation = Invitation.find(invitation_id)
    @external_author = @invitation.external_author
    @archivist = archivist_login || "An archivist"
    @token = @invitation.token
    mail(
      to: @invitation.invitee_email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Invitation to claim works"
    )
  end

  # Notifies a writer that their imported works have been claimed
  def claim_notification(creator_id, claimed_work_ids, is_user=false)
    if is_user
      creator = User.find(creator_id)
      locale = Locale.find(creator.preference.preferred_locale).iso
    else
      creator = ExternalAuthor.find(creator_id)
      locale = I18n.default_locale
    end
    @external_email = creator.email
    @claimed_works = Work.where(:id => claimed_work_ids)
    I18n.with_locale(locale) do
      mail(
        to: creator.email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Works uploaded"
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end  
  
  # Sends a batched subscription notification
  def batch_subscription_notification(subscription_id, entries)
    # Here we use find_by_id so that if the subscription is not found 
    # then the resque job does not error and we just silently fail.
    @subscription = Subscription.find_by_id(subscription_id)
    return if @subscription.nil?
    creation_entries = JSON.parse(entries)
    @creations = []
    # look up all the creations that have generated updates for this subscription
    creation_entries.each do |creation_info|
      creation_type, creation_id = creation_info.split("_")
      creation = creation_type.constantize.where(:id => creation_id).first
      next unless creation && creation.try(:posted)
      next if (creation.is_a?(Chapter) && !creation.work.try(:posted))
      next if creation.pseuds.any? {|p| p.user == User.orphan_account} # no notifications for orphan works
      # TODO: allow subscriptions to orphan_account to receive notifications

      # If the subscription notification is for a user subscription, we don't
      # want to send updates about works that have recently become anonymous.
      if @subscription.subscribable_type == 'User'
        next if creation.is_a?(Work) && creation.anonymous?
        next if creation.is_a?(Chapter) && creation.work.anonymous?
      end

      @creations << creation
    end
    
    # die if we haven't got any creations to notify about
    # see lib/bulletproof_mailer.rb
    abort_delivery if @creations.empty?

    # make sure we only notify once per creation
    @creations.uniq!
    
    subject = @subscription.subject_text(@creations.first)
    if @creations.count > 1
      subject += " and #{@creations.count - 1} more"
    end
    I18n.with_locale(Locale.find(@subscription.user.preference.preferred_locale).iso) do
      mail(
        to: @subscription.user.email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] #{subject}"
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  # Emails a user to say they have been given more invitations for their friends
  def invite_increase_notification(user_id, total)
    @user = User.find(user_id)
    @total = total
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: "#{t 'user_mailer.invite_increase_notification.subject', app_name: ArchiveConfig.APP_SHORT_NAME}"
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  # Emails a user to say that their request for invitation codes has been declined
  def invite_request_declined(user_id, total, reason)
    @user = User.find(user_id)
    @total = total
    @reason = reason
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Additional Invite Code Request Declined"
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  # Sends an admin message to a user
  def archive_notification(admin_login, user_id, subject, message)
    @user = User.find(user_id)
    @message = message
    @admin_login = admin_login
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Message - #{subject}"
      )
    end
    ensure
      I18n.locale = I18n.default_locale
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
      to: @collection.get_maintainers_email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}][#{@collection.title}] #{subject}"
    )
  end
  
  def invalid_signup_notification(collection_id, invalid_signup_ids)
    @collection = Collection.find(collection_id)
    @invalid_signups = invalid_signup_ids
    mail(
      to: @collection.get_maintainers_email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}][#{@collection.title}] Invalid Sign-ups Found"
    )
  end

  def potential_match_generation_notification(collection_id)
    @collection = Collection.find(collection_id)
    mail(
      to: @collection.get_maintainers_email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}][#{@collection.title}] Potential Assignment Generation Complete"
    )
  end

  def challenge_assignment_notification(collection_id, assigned_user_id, assignment_id)
    @collection = Collection.find(collection_id)
    @assigned_user = User.find(assigned_user_id)
    assignment = ChallengeAssignment.find(assignment_id)
    @request = (assignment.request_signup || assignment.pinch_request_signup)
    mail(
      to: @assigned_user.email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}][#{@collection.title}] Your Assignment!"
    )
  end

  # Asks a user to validate and activate their new account
  def signup_notification(user_id)
    @user = User.find(user_id)
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: t('user_mailer.signup_notification.subject', app_name: ArchiveConfig.APP_SHORT_NAME)
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  # Sends a temporary password to the user
  def reset_password(user_id, activation_code)
    @user = User.find(user_id)
    @password = activation_code
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: t('user_mailer.reset_password.subject', app_name: ArchiveConfig.APP_SHORT_NAME)
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  # Confirms to a user that their email was changed
  def change_email(user_id, old_email, new_email)
    @user = User.find(user_id)
    @old_email = old_email
    @new_email = new_email
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @old_email,
        subject: t('user_mailer.change_email.subject', app_name: ArchiveConfig.APP_SHORT_NAME)
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  ### WORKS NOTIFICATIONS ###

  # Sends email when a user is added as a co-author
  def coauthor_notification(user_id, creation_id, creation_class_name)
    @user = User.find(user_id)
    @creation = creation_class_name.constantize.find(creation_id)
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: t('user_mailer.coauthor_notification.subject', app_name: ArchiveConfig.APP_SHORT_NAME)
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  # Sends emails to authors whose stories were listed as the inspiration of another work
  def related_work_notification(user_id, related_work_id)
    @user = User.find(user_id)
    @related_work = RelatedWork.find(related_work_id)
    @related_parent_link = url_for(:controller => :works, :action => :show, :id => @related_work.parent)
    @related_child_link = url_for(:controller => :works, :action => :show, :id => @related_work.work)
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Related work notification"
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  # Emails a recipient to say that a gift has been posted for them
  def recipient_notification(user_id, work_id, collection_id=nil)
    @user = User.find(user_id)
    @work = Work.find(work_id)
    @collection = Collection.find(collection_id) if collection_id
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}]#{@collection ? '[' + @collection.title + ']' : ''} A Gift Work For You #{@collection ? 'From ' + @collection.title : ''}"
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  # Emails a prompter to say that a response has been posted to their prompt
  def prompter_notification(work_id, collection_id=nil)
    @work = Work.find(work_id)
    @collection = Collection.find(collection_id) if collection_id
    @work.challenge_claims.each do |claim|
      user = User.find(claim.request_signup.pseud.user.id)
      I18n.with_locale(Locale.find(user.preference.preferred_locale).iso) do
        mail(
          to: user.email,
          subject: "[#{ArchiveConfig.APP_SHORT_NAME}] A Response to your Prompt"
        )
      end
    end
    ensure
      I18n.locale = I18n.default_locale
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
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: user.email,
        subject: t('user_mailer.delete_work_notification.subject', app_name: ArchiveConfig.APP_SHORT_NAME)
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  # Sends email to authors when a creation is deleted by an Admin
  # NOTE: this must be sent synchronously! otherwise the work will no longer be there to send
  # TODO refactor to make it asynchronous by passing the content in the method
  def admin_deleted_work_notification(user, work)
    @user = user
    @work = work
    work_copy = generate_attachment_content_from_work(work)
    filename = work.title.gsub(/[*:?<>|\/\\\"]/,'')
    attachments["#{filename}.txt"] = {:content => work_copy}
    attachments["#{filename}.html"] = {:content => work_copy}
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: user.email,
        subject: t('user_mailer.admin_deleted_work_notification.subject', app_name: ArchiveConfig.APP_SHORT_NAME)
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  # Sends email to authors when a creation is hidden by an Admin
  def admin_hidden_work_notification(creation_id, user_id)
    @user = User.find_by_id(user_id)
    @work = Work.find_by_id(creation_id)

    mail(
        to: @user.email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Your work has been hidden by the Abuse Team"
    )
  end

  def delete_signup_notification(user, challenge_signup)
    @user = user
    @signup = challenge_signup
    signup_copy = generate_attachment_content_from_signup(@signup)
    filename = @signup.collection.title.gsub(/[*:?<>|\/\\\"]/,'')
    attachments["#{filename}.txt"] = {:content => signup_copy}
    attachments["#{filename}.html"] = {:content => signup_copy}
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: user.email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Your sign-up for #{@signup.collection.title} has been deleted"
      )
    end
    ensure
      I18n.locale = I18n.default_locale
  end

  ### OTHER NOTIFICATIONS ###

  # archive feedback
  def feedback(feedback_id)
    feedback = Feedback.find(feedback_id)
    return unless feedback.email
    @summary = feedback.summary
    @comment = feedback.comment
    @username = feedback.username if feedback.username.present?
    @language = feedback.language
    mail(
      to: feedback.email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Support - #{strip_html_breaks_simple(feedback.summary)}"
    )
  end

  def abuse_report(abuse_report_id)
    abuse_report = AbuseReport.find(abuse_report_id)
    @email = abuse_report.email
    @url = abuse_report.url
    @comment = abuse_report.comment
    mail(
      to: abuse_report.email,
      subject: "#{t 'user_mailer.abuse_report.subject', app_name: ArchiveConfig.APP_SHORT_NAME}"
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

  def generate_attachment_content_from_signup(signup)
    attachment_string =  "Collection: " + signup.collection + "<br />\n"
    signup.requests.each_with_index do |prompt, index|
      attachment_string += "Request " + index+1 + ":<br />\n"
      any_types = TagSet::TAG_TYPES.select {|type| prompt.send("any_#{type}")}
      if any_types || (prompt.tag_set && !prompt.tag_set.tags.empty?)
        attachment_string += "Tags: "
        attachment_string += prompt.tag_set && !prompt.tag_set.tags.empty? ? tag_link_list(prompt.tag_set.tags, link_to_works=true) + (any_types.empty? ? "" : ", ") : ""
        unless any_types.empty?
          attachment_string += any_types.map {|type| content_tag(:li, ts("Any %{type}", :type => type.capitalize)) }.join(", ").html_safe
        end
        if prompt.optional_tag_set && !prompt.optional_tag_set.tags.empty?
          attachment_string += "<br />\nOptional: "
          attachment_string += tag_link_list(prompt.optional_tag_set.tags, link_to_works=true)
        end
        attachment_string += "<br />\n"
      end
      unless prompt.url.blank?
        url_label = prompt.collection.challenge.send("request_url_label")
        attachment_string += url_label.blank? ? "URL" : url_label
        attachment_string += ": " + link_to(prompt.url, prompt.url) + "<br />\n"
      end
      unless prompt.description.blank?
        desc_label = prompt.collection.challenge.send("request_description_label")
        attachment_string += desc_label.blank? ? ts("Details") : desc_label
        attachment_string += ": " +  prompt.description + "<br />\n"
      end
      if prompt.anonymous?
        attachment_string += "Anonymous request" + "<br />\n"
      end
    end
    signup.offers.each_with_index do |offer, index|
      attachment_string += "Offer " + index+1 + ":<br />\n"
      any_types = TagSet::TAG_TYPES.select {|type| prompt.send("any_#{type}")}
      if any_types || (prompt.tag_set && !prompt.tag_set.tags.empty?)
        attachment_string += "Tags: "
        attachment_string += prompt.tag_set && !prompt.tag_set.tags.empty? ? tag_link_list(prompt.tag_set.tags, link_to_works=true) + (any_types.empty? ? "" : ", ") : ""
        unless any_types.empty?
          attachment_string += any_types.map {|type| content_tag(:li, ts("Any %{type}", :type => type.capitalize)) }.join(", ").html_safe
        end
        if prompt.optional_tag_set && !prompt.optional_tag_set.tags.empty?
          attachment_string += "<br />\nOptional: "
          attachment_string += tag_link_list(prompt.optional_tag_set.tags, link_to_works=true)
        end
        attachment_string += "<br />\n"
      end
      unless prompt.url.blank?
        url_label = prompt.collection.challenge.send("request_url_label")
        attachment_string += url_label.blank? ? "URL" : url_label
        attachment_string += ": " + link_to(prompt.url, prompt.url) + "<br />\n"
      end
      unless prompt.description.blank?
        desc_label = prompt.collection.challenge.send("request_description_label")
        attachment_string += desc_label.blank? ? ts("Details") : desc_label
        attachment_string += ": " +  prompt.description + "<br />\n"
      end
      if prompt.anonymous?
        attachment_string += "Anonymous request" + "<br />\n"
      end
    end
    return attachment_string
  end

  protected

end
