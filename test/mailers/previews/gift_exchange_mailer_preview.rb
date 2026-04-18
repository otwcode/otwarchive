class GiftExchangeMailerPreview < ApplicationMailerPreview
  # URL: /rails/mailers/user_mailer/no_potential_matches_notification_collection_email
  def no_potential_matches_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    GiftExchangeMailer.no_potential_matches_notification(collection.id, email)
  end

  # URL: /rails/mailers/user_mailer/no_potential_matches_maintainer
  def no_potential_matches_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    GiftExchangeMailer.no_potential_matches_notification(collection.id, email)
  end
end
