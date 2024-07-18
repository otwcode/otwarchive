class UserMailerPreview < ApplicationMailerPreview
  # Sent to a user when they submit an abuse report
  def abuse_report
    abuse_report = create(:abuse_report, url: "https://#{ArchiveConfig.APP_HOST}/tags/1984%20-%20George%20Orwell")
    UserMailer.abuse_report(abuse_report.id)
  end

  # Sends email when an archivist adds someone as a co-creator.
  def creatorship_notification_archivist
    second_creatorship, first_creator = creatorship_notification_data
    UserMailer.creatorship_notification_archivist(second_creatorship.id, first_creator.id)
  end

  # Sends email when a user is added as a co-creator
  def creatorship_notification
    second_creatorship, first_creator = creatorship_notification_data
    UserMailer.creatorship_notification(second_creatorship.id, first_creator.id)
  end

  # Sends email when a user is added as an unapproved/pending co-creator
  def creatorship_request
    second_creatorship, first_creator = creatorship_notification_data
    UserMailer.creatorship_request(second_creatorship.id, first_creator.id)
  end

  # Sent to a user when the submit a support request (AKA feedback)
  def feedback
    feedback = create(:feedback)
    UserMailer.feedback(feedback.id)
  end

  def claim_notification_registered
    work = create(:work)
    creator_id = work.pseuds.first.user.id
    UserMailer.claim_notification(creator_id, [work.id], true)
  end

  private

  def creatorship_notification_data
    first_creator = create(:user, :for_mailer_preview)
    second_creator = create(:user, :for_mailer_preview)
    work = create(:work, authors: [first_creator.default_pseud, second_creator.default_pseud])
    second_creatorship = Creatorship.find_by(creation: work, pseud: second_creator.default_pseud)
    [second_creatorship, first_creator]
  end
end
