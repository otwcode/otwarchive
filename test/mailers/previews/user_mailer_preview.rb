class UserMailerPreview < ApplicationMailerPreview
  # Sent to a user when they submit an abuse report
  def abuse_report_response
    abuse_report = create(:abuse_report)
    UserMailer.abuse_report(abuse_report.id)
  end

  # Sends email when an archivist adds someone as a co-creator.
  def creatorship_notification_archivist
    allowed_creations = [:series, :chapter, :work].freeze
    second_creatorship, first_creator = creatorship_notification_data(allowed_creations, params[:creation]&.to_sym)
    UserMailer.creatorship_notification_archivist(second_creatorship.id, first_creator.id)
  end

  # Sends email when a user is added as a co-creator
  def creatorship_notification
    allowed_creations = [:series, :chapter].freeze
    second_creatorship, first_creator = creatorship_notification_data(allowed_creations, params[:creation]&.to_sym)
    UserMailer.creatorship_notification(second_creatorship.id, first_creator.id)
  end

  # Sends email when a user is added as an unapproved/pending co-creator
  def creatorship_request
    allowed_creations = [:series, :chapter, :work].freeze
    second_creatorship, first_creator = creatorship_notification_data(allowed_creations, params[:creation]&.to_sym)
    UserMailer.creatorship_request(second_creatorship.id, first_creator.id)
  end

  # Sent to a user when the submit a support request (AKA feedback)
  def feedback_response
    feedback = create(:feedback)
    UserMailer.feedback(feedback.id)
  end

  def claim_notification_registered
    work = create(:work)
    creator_id = work.pseuds.first.user.id
    UserMailer.claim_notification(creator_id, [work.id], true)
  end

  private

  def creatorship_notification_data(allowed_creations, creation_type)
    first_creator = create(:user, login: "JayceHexmaster")
    second_creator = create(:user, login: "viktor_the_machine")

    creation_factory = allowed_creations.include?(creation_type) ? creation_type : :series
    creation = create(creation_factory, authors: [first_creator.default_pseud, second_creator.default_pseud])
    [creation.creatorships.last, first_creator]
  end
end
