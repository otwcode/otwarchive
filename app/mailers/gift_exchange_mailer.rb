class GiftExchangeMailer < ApplicationMailer
  def no_potential_matches_notification(collection_id, email)
    @collection = Collection.find(collection_id)
    @is_collection_email = (email == @collection.collection_email)
    mail(
      to: email,
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME, collection_title: @collection.title)
    )
  end
end
