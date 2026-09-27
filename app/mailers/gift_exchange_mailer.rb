class GiftExchangeMailer < ApplicationMailer
  def assignment_default_notification(collection_id, assignment_id, email)
    @assignment = ChallengeAssignment.find(assignment_id)

    return unless @assignment.offer_signup && @assignment.request_signup

    @collection = Collection.find(collection_id)
    @is_collection_email = (email == @collection.collection_email)
    mail(
      to: email,
      subject: default_i18n_subject(
        app_name: ArchiveConfig.APP_SHORT_NAME,
        collection_title: @collection.title,
        offer_byline: @assignment.offering_pseud.byline
      )
    )
  end

  def assignments_sent_notification(collection_id, email)
    @collection = Collection.find(collection_id)
    @is_collection_email = (email == @collection.collection_email)
    mail(
      to: email,
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME, collection_title: @collection.title)
    )
  end

  def invalid_signup_notification(collection_id, invalid_signup_ids, email)
    @collection = Collection.find(collection_id)
    @invalid_signups = invalid_signup_ids
    @is_collection_email = (email == @collection.collection_email)
    mail(
      to: email,
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME, collection_title: @collection.title)
    )
  end

  def no_potential_matches_notification(collection_id, email)
    @collection = Collection.find(collection_id)
    @is_collection_email = (email == @collection.collection_email)
    mail(
      to: email,
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME, collection_title: @collection.title)
    )
  end

  # This is sent at the end of matching, i.e., after assignments are generated.
  # It is also sent when assignments are regenerated.
  def potential_match_generation_notification(collection_id, email)
    @collection = Collection.find(collection_id)
    @is_collection_email = (email == @collection.collection_email)
    mail(
      to: email,
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME, collection_title: @collection.title)
    )
  end
end
