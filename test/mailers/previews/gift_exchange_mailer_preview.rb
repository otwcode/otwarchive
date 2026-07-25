class GiftExchangeMailerPreview < ApplicationMailerPreview
  # URL: /rails/mailers/gift_exchange_mailer/assignment_default_notification_collection_email
  def assignment_default_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    challenge_assignment = create(:challenge_assignment)
    GiftExchangeMailer.assignment_default_notification(collection.id, challenge_assignment.id, email)
  end

  # URL: /rails/mailers/gift_exchange_mailer/assignment_default_notification_maintainer
  def assignment_default_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    challenge_assignment = create(:challenge_assignment)
    GiftExchangeMailer.assignment_default_notification(collection.id, challenge_assignment.id, email)
  end

  # URL: /rails/mailers/gift_exchange_mailer/assignments_sent_notification_collection_email
  def assignments_sent_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    GiftExchangeMailer.assignments_sent_notification(collection.id, email)
  end

  # URL: /rails/mailers/gift_exchange_mailer/assignments_sent_notification_maintainer
  def assignments_sent_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    GiftExchangeMailer.assignments_sent_notification(collection.id, email)
  end

  # URL: /rails/mailers/gift_exchange_mailer/invalid_signup_notification_collection_email?signup_count=2
  def invalid_signup_notification_collection_email
    signup_count = params[:signup_count] ? params[:signup_count].to_i : 1
    collection = create(:collection, email: "collection@example.com")
    invalid_signup_ids = create_list(:challenge_signup, signup_count).map(&:id)
    email = collection.collection_email
    GiftExchangeMailer.invalid_signup_notification(collection.id, invalid_signup_ids, email)
  end

  # URL: /rails/mailers/gift_exchange_mailer/invalid_signup_notification_maintainer?signup_count=2
  def invalid_signup_notification_maintainer
    signup_count = params[:signup_count] ? params[:signup_count].to_i : 1
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    invalid_signup_ids = create_list(:challenge_signup, signup_count).map(&:id)
    email = user.email
    GiftExchangeMailer.invalid_signup_notification(collection.id, invalid_signup_ids, email)
  end

  # URL: /rails/mailers/gift_exchange_mailer/no_potential_matches_notification_collection_email
  def no_potential_matches_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    GiftExchangeMailer.no_potential_matches_notification(collection.id, email)
  end

  # URL: /rails/mailers/gift_exchange_mailer/no_potential_matches_notification_maintainer
  def no_potential_matches_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    GiftExchangeMailer.no_potential_matches_notification(collection.id, email)
  end

  # URL: /rails/mailers/gift_exchange_mailer/potential_match_generation_notification_collection_email
  def potential_match_generation_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    GiftExchangeMailer.potential_match_generation_notification(collection.id, email)
  end

  # URL: /rails/mailers/gift_exchange_mailer/potential_match_generation_notification_maintainer
  def potential_match_generation_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    GiftExchangeMailer.potential_match_generation_notification(collection.id, email)
  end
end
