class UserMailer < BulletproofMailer::Base
  include Resque::Mailer # see README in this directory

  layout 'mailer'

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
      subject: t("user_mailer.invitation.subject", app_name: ArchiveConfig.APP_SHORT_NAME)
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
      subject: t("user_mailer.invitation_to_claim.subject", app_name: ArchiveConfig.APP_SHORT_NAME)
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
    @claimed_works = Work.where(id: claimed_work_ids)
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
    @subscription = Subscription.find_by(id: subscription_id)
    return if @subscription.nil?
    creation_entries = JSON.parse(entries)
    @creations = []
    # look up all the creations that have generated updates for this subscription
    creation_entries.each do |creation_info|
      creation_type, creation_id = creation_info.split("_")
      creation = creation_type.constantize.where(id: creation_id).first
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
      subject += t(".subject_linker", extra: @creations.count - 1)
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
        subject: t('user_mailer.invite_request_declined.subject', app_name: ArchiveConfig.APP_SHORT_NAME)
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
      subject: t("user_mailer.challenge_assignment_notification.subject", app_name: ArchiveConfig.APP_SHORT_NAME, collection_title: @collection.title)
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

  # Sends email when an archivist adds someone as a co-creator.
  def creatorship_notification_archivist(creatorship_id, archivist_id)
    @creatorship = Creatorship.find(creatorship_id)
    @archivist = User.find(archivist_id)
    @user = @creatorship.pseud.user
    @creation = @creatorship.creation
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: t("user_mailer.creatorship_notification_archivist.subject",
                   app_name: ArchiveConfig.APP_SHORT_NAME)
      )
    end
  ensure
    I18n.locale = I18n.default_locale
  end

  # Sends email when a user is added as a co-creator
  def creatorship_notification(creatorship_id, adding_user_id)
    @creatorship = Creatorship.find(creatorship_id)
    @adding_user = User.find(adding_user_id)
    @user = @creatorship.pseud.user
    @creation = @creatorship.creation
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: t("user_mailer.creatorship_notification.subject",
                   app_name: ArchiveConfig.APP_SHORT_NAME)
      )
    end
  ensure
    I18n.locale = I18n.default_locale
  end

  # Sends email when a user is added as an unapproved/pending co-creator
  def creatorship_invitation(creatorship_id, inviting_user_id)
    @creatorship = Creatorship.find(creatorship_id)
    @inviting_user = User.find(inviting_user_id)
    @user = @creatorship.pseud.user
    @creation = @creatorship.creation
    I18n.with_locale(Locale.find(@user.preference.preferred_locale).iso) do
      mail(
        to: @user.email,
        subject: t("user_mailer.creatorship_invitation.subject",
                   app_name: ArchiveConfig.APP_SHORT_NAME)
      )
    end
  ensure
    I18n.locale = I18n.default_locale
  end

  # Sends emails to authors whose stories were listed as the inspiration of another work
  def related_work_notification(user_id, related_work_id)
    @user = User.find(user_id)
    @related_work = RelatedWork.find(related_work_id)
    @related_parent_link = url_for(controller: :works, action: :show, id: @related_work.parent)
    @related_child_link = url_for(controller: :works, action: :show, id: @related_work.work)
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
    work_copy = ::Mail::Encodings::Base64.encode(work_copy)
    filename = work.title.gsub(/[*:?<>|\/\\\"]/,'')
    attachments["#{filename}.txt"] = { content: work_copy, encoding: "base64" }
    attachments["#{filename}.html"] = { content: work_copy, encoding: "base64" }
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
    work_copy = ::Mail::Encodings::Base64.encode(work_copy)
    filename = work.title.gsub(/[*:?<>|\/\\\"]/,'')
    attachments["#{filename}.txt"] = { content: work_copy, encoding: "base64" }
    attachments["#{filename}.html"] = { content: work_copy, encoding: "base64" }
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
    @user = User.find_by(id: user_id)
    @work = Work.find_by(id: creation_id)

    mail(
        to: @user.email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Your work has been hidden by the Abuse Team"
    )
  end

  def admin_spam_work_notification(creation_id, user_id)
    @user = User.find_by(id: user_id)
    @work = Work.find_by(id: creation_id)

    mail(
        to: @user.email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Your work was hidden as spam"
    )
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

  protected

end
