class UserMailerPreview < ApplicationMailerPreview
  # Sent to a user when they submit an abuse report
  def abuse_report
    abuse_report = create(:abuse_report, url: "https://#{ArchiveConfig.APP_HOST}/tags/1984%20-%20George%20Orwell")
    UserMailer.abuse_report(abuse_report.id)
  end

  [:series, :chapter, :work].each do |creation_type|
    # Sends email when an archivist adds someone as a co-creator.
    define_method :"creatorship_notification_archivist_#{creation_type}" do
      second_creatorship, first_creator = creatorship_notification_data(creation_type)
      UserMailer.creatorship_notification_archivist(second_creatorship.id, first_creator.id)
    end

    # Sends email when a user is added as an unapproved/pending co-creator
    define_method :"creatorship_request_#{creation_type}" do
      second_creatorship, first_creator = creatorship_notification_data(creation_type)
      UserMailer.creatorship_request(second_creatorship.id, first_creator.id)
    end

    # AO3-6710: Users cannot directly add a co-creator to a work, so creatorship_notification will never be sent for works
    next if creation_type == :work

    # Sends email when a user is added as a co-creator
    define_method :"creatorship_notification_#{creation_type}" do
      second_creatorship, first_creator = creatorship_notification_data(creation_type)
      UserMailer.creatorship_notification(second_creatorship.id, first_creator.id)
    end
  end

  # Sent to a user when the submit a support request (AKA feedback)
  def feedback
    feedback = create(:feedback)
    UserMailer.feedback(feedback.id)
  end

  # Sent by gift exchanges to the participants
  # Variant with tag fields set to "Any" and no due date
  # URL: /rails/mailers/user_mailer/challenge_assignment_notification_any?sent_at=2025-01-23T20:00
  def challenge_assignment_notification_any
    assignment = create(:challenge_assignment, sent_at: (params[:sent_at] ? params[:sent_at].to_time : Time.current))

    signup = assignment.request_signup
    signup.update(pseud: create(:user, :for_mailer_preview).default_pseud)

    # Fill all tag fields with "Any"
    prompt = signup.requests.first
    TagSet::TAG_TYPES.each do |type|
      prompt.send(:"any_#{type}=", true)
    end
    prompt.title = "This is a title"
    prompt.save!

    UserMailer.challenge_assignment_notification(assignment.collection.id, assignment.offering_user.id, assignment.id)
  end

  # Sent by gift exchanges to the participants
  # Variant with flexible due date, 3 tags per type and all fields filled out
  # URL: /rails/mailers/user_mailer/challenge_assignment_notification_filled?sent_at=2025-01-23T20:00&due=2021-12-15T13:45
  def challenge_assignment_notification_filled
    assignment = create(:challenge_assignment, sent_at: (params[:sent_at] ? params[:sent_at].to_time : Time.current))

    challenge = assignment.collection.challenge
    challenge.update(assignments_due_at: params[:due] ? params[:due].to_time : Time.current)

    signup = assignment.request_signup
    signup.update(pseud: create(:user, :for_mailer_preview).default_pseud)

    # Allow up to 3 tags per type
    request_restriction = challenge.request_restriction
    TagSet::TAG_TYPES.each do |type|
      request_restriction.send(:"#{type}_num_allowed=", 3)
    end
    request_restriction.save!

    # Tag set with 3 tags per type
    tag_set = create(:tag_set, tags: [])
    tag_set.archive_warning_tagnames = [ArchiveConfig.WARNING_VIOLENCE_TAG_NAME, ArchiveConfig.WARNING_DEATH_TAG_NAME, ArchiveConfig.WARNING_NONCON_TAG_NAME].join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
    tag_set.rating_tagnames = [ArchiveConfig.RATING_EXPLICIT_TAG_NAME, ArchiveConfig.RATING_MATURE_TAG_NAME, ArchiveConfig.RATING_TEEN_TAG_NAME].join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
    tag_set.category_tagnames = [ArchiveConfig.CATEGORY_GEN_TAG_NAME, ArchiveConfig.CATEGORY_HET_TAG_NAME, ArchiveConfig.CATEGORY_SLASH_TAG_NAME].join(ArchiveConfig.DELIMITER_FOR_OUTPUT)
    %w[fandom character relationship freeform].each do |type|
      tag_set.tags += [create(:"canonical_#{type}", :for_mailer_preview), create(:"canonical_#{type}", :for_mailer_preview), create(:"canonical_#{type}", :for_mailer_preview)]
    end
    tag_set.save!

    prompt = signup.requests.first
    prompt.tag_set = tag_set
    prompt.title = "This is a title"
    prompt.url = "https://example.com/"
    prompt.optional_tag_set = create(:tag_set, tags: [create(:freeform, :for_mailer_preview), create(:freeform, :for_mailer_preview), create(:freeform, :for_mailer_preview)])
    prompt.save!

    UserMailer.challenge_assignment_notification(assignment.collection.id, assignment.offering_user.id, assignment.id)
  end

  def claim_notification
    work = create(:work)
    creator_id = work.pseuds.first.user.id
    UserMailer.claim_notification(creator_id, [work.id])
  end
  
  def invite_request_declined
    user = create(:user, :for_mailer_preview)
    total = params[:total] ? params[:total].to_i : 1
    reason = "test reason"
    UserMailer.invite_request_declined(user.id, total, reason)
  end

  def change_email
    user = create(:user, :for_mailer_preview)
    old_email = user.email
    new_email = "new_email"
    UserMailer.change_email(user.id, old_email, new_email)
  end

  # Sends email when collection item changes status: anonymous_unrevealed
  def anonymous_or_unrevealed_notification_status_anonymous_and_unrevealed
    user, collection, item = anonymous_or_unrevealed_data(:anonymous_unrevealed_collection)
    newly_anonymous = true
    newly_unrevealed = true
    UserMailer.anonymous_or_unrevealed_notification(
      user.id, item.id, collection.id,
      anonymous: newly_anonymous, unrevealed: newly_unrevealed
    )
  end

  # Sends email when collection item changes status: anonymous
  def anonymous_or_unrevealed_notification_status_anonymous
    user, collection, item = anonymous_or_unrevealed_data(:anonymous_collection)
    newly_anonymous = true
    newly_unrevealed = false
    UserMailer.anonymous_or_unrevealed_notification(
      user.id, item.id, collection.id,
      anonymous: newly_anonymous, unrevealed: newly_unrevealed
    )
  end

  # Sends email when collection item changes status: unrevealed
  def anonymous_or_unrevealed_notification_status_unrevealed
    user, collection, item = anonymous_or_unrevealed_data(:unrevealed_collection)
    newly_anonymous = false
    newly_unrevealed = true
    UserMailer.anonymous_or_unrevealed_notification(
      user.id, item.id, collection.id,
      anonymous: newly_anonymous, unrevealed: newly_unrevealed
    )
  end

  def invite_increase_notification
    user = create(:user, :for_mailer_preview)
    total = params[:total] || 1
    UserMailer.invite_increase_notification(user.id, total.to_i)
  end

  def archivist_added_to_collection_notification
    work = create(:work)
    collection = create(:collection)
    user = create(:user, :for_mailer_preview)
    UserMailer.archivist_added_to_collection_notification(user.id, work.id, collection.id)
  end

  def admin_hidden_work_notification
    work = create(:work)
    user = create(:user, :for_mailer_preview)
    UserMailer.admin_hidden_work_notification(work, user.id)
  end

  def admin_deleted_work_notification
    work = create(:work)
    user = create(:user, :for_mailer_preview)
    UserMailer.admin_deleted_work_notification(user, work)
  end

  private

  def creatorship_notification_data(creation_type)
    first_creator = create(:user, :for_mailer_preview)
    second_creator = create(:user, :for_mailer_preview)
    creation = create(creation_type, authors: [first_creator.default_pseud, second_creator.default_pseud])
    [creation.creatorships.last, first_creator]
  end

  def anonymous_or_unrevealed_data(status)
    user = create(:user, :for_mailer_preview)
    collection = create(status)
    item = create(:work, authors: [user.default_pseud], collections: [collection])
    [user, collection, item]
  end
end
