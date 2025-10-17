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

  def prompter_notification
    creator_count = params[:creator_count] ? params[:creator_count].to_i : 1

    user = create(:user, :for_mailer_preview)
    work = prompter_notification_data(creator_count)
    UserMailer.prompter_notification(user.id, work.id)
  end

  def prompter_notification_collection
    creator_count = params[:creator_count] ? params[:creator_count].to_i : 1

    user = create(:user, :for_mailer_preview)
    collection = create(:collection)
    work = prompter_notification_data(creator_count)
    UserMailer.prompter_notification(user.id, work.id, collection.id)
  end

  def prompter_notification_collection_anon
    user = create(:user, :for_mailer_preview)
    collection = create(:collection)
    work = create(:work, summary: Faker::Lorem.paragraph(sentence_count: 3), collections: [create(:anonymous_collection)])
    UserMailer.prompter_notification(user.id, work.id, collection.id)
  end

  def claim_notification
    work = create(:work)
    creator_id = work.pseuds.first.user.id
    UserMailer.claim_notification(creator_id, [work.id])
  end

  def invitation_to_claim
    archivist = create(:user, :for_mailer_preview)
    external_author = create(:external_author)
    external_author_name = create(:external_author_name, external_author: external_author, name: "Pluto")
    invitation = create(:invitation, external_author: external_author)
    create(:external_creatorship,
           creation: create(:work, title: Faker::Book.title),
           external_author_name: external_author_name)
    create(:external_creatorship,
           creation: create(:work, title: Faker::Book.title),
           external_author_name: external_author_name)

    UserMailer.invitation_to_claim(invitation.id, archivist.login)
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
    new_email = "new_email@example.com"
    UserMailer.change_email(user.id, old_email, new_email)
  end

  def change_username
    user = create(:user, :for_mailer_preview)
    user.renamed_at = Time.current
    old_username = "old_username"
    UserMailer.change_username(user, old_username)
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

  # Send notification for a regular gift work
  def recipient_notification_status_regular
    count = params[:count].to_i || 1
    user, work = recipient_notification_data(count)
    UserMailer.recipient_notification(user.id, work.id)
  end

  # Send notification for a gift work in a collection
  def recipient_notification_status_collection
    count = params[:count].to_i || 1
    user, work = recipient_notification_data(count)
    collection = create(:collection)
    UserMailer.recipient_notification(user.id, work.id, collection.id)
  end

  def potential_match_generation_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    UserMailer.potential_match_generation_notification(collection.id, email)
  end

  def potential_match_generation_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    UserMailer.potential_match_generation_notification(collection.id, email)
  end

  def invalid_signup_notification_collection_email
    signup_count = params[:signup_count] ? params[:signup_count].to_i : 1
    collection = create(:collection, email: "collection@example.com")
    invalid_signup_ids = create_list(:challenge_signup, signup_count).map(&:id)
    email = collection.collection_email
    UserMailer.invalid_signup_notification(collection.id, invalid_signup_ids, email)
  end

  def invalid_signup_notification_maintainer
    signup_count = params[:signup_count] ? params[:signup_count].to_i : 1
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    invalid_signup_ids = create_list(:challenge_signup, signup_count).map(&:id)
    email = user.email
    UserMailer.invalid_signup_notification(collection.id, invalid_signup_ids, email)
  end

  def assignments_sent_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    UserMailer.assignments_sent_notification(collection.id, email)
  end

  def assignments_sent_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    UserMailer.assignments_sent_notification(collection.id, email)
  end

  def assignment_default_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    challenge_assignment = create(:challenge_assignment)
    offer_byline = challenge_assignment.offer_byline
    request_byline = challenge_assignment.request_byline
    UserMailer.assignment_default_notification(collection.id, offer_byline, request_byline, email)
  end

  def assignment_default_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    challenge_assignment = create(:challenge_assignment)
    offer_byline = challenge_assignment.offer_byline
    request_byline = challenge_assignment.request_byline
    UserMailer.assignment_default_notification(collection.id, offer_byline, request_byline, email)
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

  def invited_to_collection_notification
    user = create(:user, :for_mailer_preview)
    work = create(:work)
    collection = create(:collection)
    UserMailer.invited_to_collection_notification(user.id, work.id, collection.id)
  end

  def admin_spam_work_notification
    work = create(:work)
    user = create(:user, :for_mailer_preview)
    UserMailer.admin_spam_work_notification(work.id, user.id)
  end

  def admin_hidden_work_notification
    count = params[:count] ? params[:count].to_i : 1
    works = create_list(:work, count) do |work|
      work.title = Faker::Book.title
      work.save!
    end
    user = create(:user, :for_mailer_preview)
    UserMailer.admin_hidden_work_notification(works.map(&:id), user.id)
  end

  def admin_deleted_work_notification
    work = create(:work)
    user = create(:user, :for_mailer_preview)
    UserMailer.admin_deleted_work_notification(user, work)
  end

  def delete_work_notification_self
    user = create(:user, :for_mailer_preview)
    work = create(:work, authors: [user.default_pseud])
    UserMailer.delete_work_notification(user, work, user)
  end

  def delete_work_notification_co_creator
    first_creator = create(:user, :for_mailer_preview)
    second_creator = create(:user, :for_mailer_preview)
    work = create(:work, authors: [first_creator.default_pseud, second_creator.default_pseud])
    UserMailer.delete_work_notification(first_creator, work, second_creator)
  end

  def related_work_notification
    creator_count = params[:creator_count] ? params[:creator_count].to_i : 1
    user = create(:user, :for_mailer_preview)
    parent_work = create(:work, authors: [user.default_pseud], title: "Inspiration")
    child_work_pseuds = create_list(:user, creator_count).map(&:default_pseud)
    child_work = create(:work, authors: child_work_pseuds)
    related_work = create(:related_work, parent_id: parent_work.id, work_id: child_work.id)
    UserMailer.related_work_notification(user.id, related_work.id)
  end

  def related_work_notification_anon
    user = create(:user, :for_mailer_preview)
    parent_work = create(:work, authors: [user.default_pseud], title: "Inspiration")
    child_work = create(:work, collections: [create(:anonymous_collection)])
    related_work = create(:related_work, parent_id: parent_work.id, work_id: child_work.id)
    UserMailer.related_work_notification(user.id, related_work.id)
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

  def recipient_notification_data(count)
    fandoms = []
    relationships = []
    characters = []
    tags = []
    series_list = []

    count = 1 if count < 1
    (1..count).each do |n|
      fandoms.append("fandom_#{n}")
      relationships.append("relationship_#{n}")
      characters.append("character_#{n}")
      tags.append("tag_#{n}")
      series_list.append(create(:series))
    end
    warnings = ArchiveWarning.canonical.first(count).pluck(:name)

    user = create(:user, :for_mailer_preview)
    work = create(
      :work,
      authors: [user.default_pseud],
      expected_number_of_chapters: count,
      rating_string: ArchiveConfig.RATING_DEFAULT_TAG_NAME,
      fandom_string: fandoms,
      relationship_string: relationships,
      character_string: characters,
      freeform_string: tags,
      archive_warning_strings: warnings,
      summary: Faker::Lorem.paragraph(sentence_count: count),
      chapter_attributes: { content: count.times.map { Faker::Lorem.characters(number: 11) } },
      series: series_list
    )
    [user, work]
  end

  def prompter_notification_data(creator_count)
    create(:work,
           summary: Faker::Lorem.paragraph(sentence_count: 3),
           authors: create_list(:user, creator_count).map(&:default_pseud))
  end
end
