class UserMailerPreview < ApplicationMailerPreview
  # Sent to a user when they submit an abuse report
  # URL: /rails/mailers/user_mailer/abuse_report
  def abuse_report
    abuse_report = create(:abuse_report, url: "https://#{ArchiveConfig.APP_HOST}/tags/1984%20-%20George%20Orwell")
    UserMailer.abuse_report(abuse_report.id)
  end

  [:series, :chapter, :work].each do |creation_type|
    # Sends email when an archivist adds someone as a co-creator.
    # URL: /rails/mailers/user_mailer/creatorship_notification_archivist_series
    # URL: /rails/mailers/user_mailer/creatorship_notification_archivist_chapter
    # URL: /rails/mailers/user_mailer/creatorship_notification_archivist_work
    define_method :"creatorship_notification_archivist_#{creation_type}" do
      second_creatorship, first_creator = creatorship_notification_data(creation_type)
      UserMailer.creatorship_notification_archivist(second_creatorship.id, first_creator.id)
    end

    # Sends email when a user is added as an unapproved/pending co-creator
    # URL: /rails/mailers/user_mailer/creatorship_request_series
    # URL: /rails/mailers/user_mailer/creatorship_request_chapter
    # URL: /rails/mailers/user_mailer/creatorship_request_work
    define_method :"creatorship_request_#{creation_type}" do
      second_creatorship, first_creator = creatorship_notification_data(creation_type)
      UserMailer.creatorship_request(second_creatorship.id, first_creator.id)
    end

    # AO3-6710: Users cannot directly add a co-creator to a work, so creatorship_notification will never be sent for works
    next if creation_type == :work

    # Sends email when a user is added as a co-creator
    # URL: /rails/mailers/user_mailer/creatorship_notification_series
    # URL: /rails/mailers/user_mailer/creatorship_notification_chapter
    define_method :"creatorship_notification_#{creation_type}" do
      second_creatorship, first_creator = creatorship_notification_data(creation_type)
      UserMailer.creatorship_notification(second_creatorship.id, first_creator.id)
    end
  end

  # Sent to a user when the submit a support request (AKA feedback)
  # URL: /rails/mailers/user_mailer/feedback
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

  # URL: /rails/mailers/user_mailer/prompter_notification?creator_count=2
  def prompter_notification
    creator_count = params[:creator_count] ? params[:creator_count].to_i : 1

    user = create(:user, :for_mailer_preview)
    work = prompter_notification_data(creator_count)
    UserMailer.prompter_notification(user.id, work.id)
  end

  # URL: /rails/mailers/user_mailer/prompter_notification_collection?creator_count=2
  def prompter_notification_collection
    creator_count = params[:creator_count] ? params[:creator_count].to_i : 1

    user = create(:user, :for_mailer_preview)
    collection = create(:collection)
    work = prompter_notification_data(creator_count)
    UserMailer.prompter_notification(user.id, work.id, collection.id)
  end

  # URL: /rails/mailers/user_mailer/prompter_notification_collection_anon
  def prompter_notification_collection_anon
    user = create(:user, :for_mailer_preview)
    collection = create(:collection)
    work = create(:work, summary: Faker::Lorem.paragraph(sentence_count: 3), collections: [create(:anonymous_collection)])
    UserMailer.prompter_notification(user.id, work.id, collection.id)
  end

  # URL: /rails/mailers/user_mailer/claim_notification
  def claim_notification
    work = create(:work)
    creator_id = work.pseuds.first.user.id
    UserMailer.claim_notification(creator_id, [work.id])
  end

  # URL: /rails/mailers/user_mailer/invitation_to_claim
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

  # URL: /rails/mailers/user_mailer/invitation
  def invitation_by_other_user
    inviting_user = create(:user)
    invitation = create(:invitation, creator: inviting_user)
    UserMailer.invitation(invitation.id)
  end

  # URL: /rails/mailers/user_mailer/invitation
  def invitation_by_queue
    invitation = create(:invitation)
    UserMailer.invitation(invitation.id)
  end

  # URL: /rails/mailers/user_mailer/invite_request_declined?total=3
  def invite_request_declined
    user = create(:user, :for_mailer_preview)
    total = params[:total] ? params[:total].to_i : 1
    reason = "test reason"
    UserMailer.invite_request_declined(user.id, total, reason)
  end

  # URL: /rails/mailers/user_mailer/change_email
  def change_email
    user = create(:user, :for_mailer_preview)
    old_email = user.email
    new_email = "new_email@example.com"
    UserMailer.change_email(user.id, old_email, new_email)
  end

  # URL: /rails/mailers/user_mailer/batch_subscription_notification_work?work_id=2
  # Preview a subscription notification for a work. Replace 123 with the id of
  # any work on your environment. This will generate a subscription notification
  # for all but the first chapter of the work, e.g., a 3-chapter work will have
  # 2 chapters listed in the email. For 1-chapter works, it will use the sole
  # chapter.
  def batch_subscription_notification_work
    work = params[:work_id].present? ? Work.find_by(id: params[:work_id]) : create(:work, authors: [create(:user, :for_mailer_preview).default_pseud])
    subscription = create(:subscription, subscribable: work)
    chapter_ids = work.chapter_ids.drop(1).presence || work.chapter_ids

    entries = chapter_ids.map { |id| "Chapter_#{id}" }
    UserMailer.batch_subscription_notification(subscription.id, entries.to_json)
  end

  # URL: /rails/mailers/user_mailer/batch_subscription_notification_user?user=NAME&work_ids[]=2&work_ids[]=3&chapter_ids[]=8
  # Preview a subscription notification for a user, which can contain chapters
  # and/or works. You can specify the user and the works and/or chapters or
  # we'll make a user, two works, and two chapters.
  def batch_subscription_notification_user
    if params[:user] && (params[:work_ids] || params[:chapter_ids])
      user = User.find_by(login: params[:user])
      work_ids = params[:work_ids] || []
      chapter_ids = params[:chapter_ids] || []
    else
      user = create(:user, :for_mailer_preview)
      first_work = create(:work, authors: [user.default_pseud], title: "First New Work")
      second_work = create(:work, authors: [user.default_pseud], title: "Second New Work", expected_number_of_chapters: nil, backdate: true)
      third_work = create(:work, authors: [user.default_pseud], title: "Existing Work", expected_number_of_chapters: 9)
      first_chapter = create(:chapter, work: second_work, authors: [user.default_pseud], position: 2, summary: "great summary")
      second_chapter = create(:chapter, work: third_work, authors: [user.default_pseud], position: 2)
      work_ids = [first_work.id, second_work.id]
      chapter_ids = [first_chapter.id, second_chapter.id]
    end

    subscription = create(:subscription, subscribable: user)

    entries = []
    work_ids.each { |id| entries << "Work_#{id}" }
    chapter_ids.each { |id| entries << "Chapter_#{id}" }
    UserMailer.batch_subscription_notification(subscription.id, entries.to_json)
  end

  # URL: /rails/mailers/user_mailer/batch_subscription_notification_series?series_id=NAME&work_ids[]=2&work_ids[]=3&chapter_ids[]=8
  # Preview a subscription notification for a series, which can contain chapters
  # and/or works. You can specify the series and the works and/or chapters or
  # we'll make a series, two works, and one chapters.
  def batch_subscription_notification_series
    if params[:series_id] && (params[:work_ids] || params[:chapter_ids])
      series = Series.find_by(id: params[:series_id])
      work_ids = params[:work_ids] || []
      chapter_ids = params[:chapter_ids] || []
    else
      user = create(:user, :for_mailer_preview)
      first_work = create(:work, authors: [user.default_pseud], title: "First New Work")
      second_work = create(:work, authors: [user.default_pseud], title: "Second New Work", expected_number_of_chapters: nil, backdate: true)
      third_work = create(:work, authors: [user.default_pseud, create(:user, :for_mailer_preview).default_pseud], title: "Existing Work", expected_number_of_chapters: 9)
      series = create(:series, authors: [user.default_pseud], works: [first_work, second_work, third_work])
      first_chapter = create(:chapter, work: third_work, authors: [user.default_pseud], position: 2)
      work_ids = [first_work.id, second_work.id]
      chapter_ids = [first_chapter.id]
    end

    subscription = create(:subscription, subscribable: series)

    entries = []
    work_ids.each { |id| entries << "Work_#{id}" }
    chapter_ids.each { |id| entries << "Chapter_#{id}" }
    UserMailer.batch_subscription_notification(subscription.id, entries.to_json)
  end

  # URL: /rails/mailers/user_mailer/change_username
  def change_username
    user = create(:user, :for_mailer_preview)
    user.renamed_at = Time.current
    old_username = "old_username"
    UserMailer.change_username(user, old_username)
  end

  # Sends email when collection item changes status: anonymous_unrevealed
  # URL: /rails/mailers/user_mailer/anonymous_or_unrevealed_notification_status_anonymous_and_unrevealed
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
  # URL: /rails/mailers/user_mailer/anonymous_or_unrevealed_notification_status_anonymous
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
  # URL: /rails/mailers/user_mailer/anonymous_or_unrevealed_notification_status_unrevealed
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
  # URL: /rails/mailers/user_mailer/recipient_notification_status_regular?count=2
  def recipient_notification_status_regular
    count = params[:count].to_i || 1
    user, work = recipient_notification_data(count)
    UserMailer.recipient_notification(user.id, work.id)
  end

  # Send notification for a gift work in a collection
  # URL: /rails/mailers/user_mailer/recipient_notification_status_collection?count=2
  def recipient_notification_status_collection
    count = params[:count].to_i || 1
    user, work = recipient_notification_data(count)
    collection = create(:collection)
    UserMailer.recipient_notification(user.id, work.id, collection.id)
  end

  # URL: /rails/mailers/user_mailer/potential_match_generation_notification_collection_email
  def potential_match_generation_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    UserMailer.potential_match_generation_notification(collection.id, email)
  end

  # URL: /rails/mailers/user_mailer/potential_match_generation_notification_maintainer
  def potential_match_generation_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    UserMailer.potential_match_generation_notification(collection.id, email)
  end

  # URL: /rails/mailers/user_mailer/invalid_signup_notification_collection_email?signup_count=2
  def invalid_signup_notification_collection_email
    signup_count = params[:signup_count] ? params[:signup_count].to_i : 1
    collection = create(:collection, email: "collection@example.com")
    invalid_signup_ids = create_list(:challenge_signup, signup_count).map(&:id)
    email = collection.collection_email
    UserMailer.invalid_signup_notification(collection.id, invalid_signup_ids, email)
  end

  # URL: /rails/mailers/user_mailer/invalid_signup_notification_maintainer?signup_count=2
  def invalid_signup_notification_maintainer
    signup_count = params[:signup_count] ? params[:signup_count].to_i : 1
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    invalid_signup_ids = create_list(:challenge_signup, signup_count).map(&:id)
    email = user.email
    UserMailer.invalid_signup_notification(collection.id, invalid_signup_ids, email)
  end

  # URL: /rails/mailers/user_mailer/assignments_sent_notification_collection_email
  def assignments_sent_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    UserMailer.assignments_sent_notification(collection.id, email)
  end

  # URL: /rails/mailers/user_mailer/assignments_sent_notification_maintainer
  def assignments_sent_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    UserMailer.assignments_sent_notification(collection.id, email)
  end

  # URL: /rails/mailers/user_mailer/assignment_default_notification_collection_email
  def assignment_default_notification_collection_email
    collection = create(:collection, email: "collection@example.com")
    email = collection.collection_email
    challenge_assignment = create(:challenge_assignment)
    UserMailer.assignment_default_notification(collection.id, challenge_assignment.id, email)
  end

  # URL: /rails/mailers/user_mailer/assignment_default_notification_maintainer
  def assignment_default_notification_maintainer
    user = create(:user, :for_mailer_preview)
    collection = create(:collection, owners: [user.default_pseud])
    email = user.email
    challenge_assignment = create(:challenge_assignment)
    UserMailer.assignment_default_notification(collection.id, challenge_assignment.id, email)
  end

  # URL: /rails/mailers/user_mailer/invite_increase_notification?total=2
  def invite_increase_notification
    user = create(:user, :for_mailer_preview)
    total = params[:total] || 1
    UserMailer.invite_increase_notification(user.id, total.to_i)
  end

  # URL: /rails/mailers/user_mailer/archivist_added_to_collection_notification
  def archivist_added_to_collection_notification
    work = create(:work)
    collection = create(:collection)
    user = create(:user, :for_mailer_preview)
    UserMailer.archivist_added_to_collection_notification(user.id, work.id, collection.id)
  end

  # URL: /rails/mailers/user_mailer/invited_to_collection_notification
  def invited_to_collection_notification
    user = create(:user, :for_mailer_preview)
    work = create(:work)
    collection = create(:collection)
    UserMailer.invited_to_collection_notification(user.id, work.id, collection.id)
  end

  # URL: /rails/mailers/user_mailer/admin_spam_work_notification
  def admin_spam_work_notification
    work = create(:work)
    user = create(:user, :for_mailer_preview)
    UserMailer.admin_spam_work_notification(work.id, user.id)
  end

  # URL: /rails/mailers/user_mailer/admin_hidden_work_notification?count=2
  def admin_hidden_work_notification
    count = params[:count] ? params[:count].to_i : 1
    works = create_list(:work, count) do |work|
      work.title = Faker::Book.title
      work.save!
    end
    user = create(:user, :for_mailer_preview)
    UserMailer.admin_hidden_work_notification(works.map(&:id), user.id)
  end

  # Sent to a user when an admin deletes their work
  # URL: /rails/mailers/user_mailer/admin_deleted_work_notification?work_id=2
  def admin_deleted_work_notification
    if params[:work_id]
      work = Work.find_by(id: params[:work_id])
      user = work.users.first
    else
      work = create(:work)
      user = create(:user, :for_mailer_preview)
    end
    UserMailer.admin_deleted_work_notification(user, work)
  end

  # Sent to a user when they delete a work
  # URL: /rails/mailers/user_mailer/delete_work_notification_self?work_id=2
  def delete_work_notification_self
    if params[:work_id]
      work = Work.find_by(id: params[:work_id])
      user = work.users.first
    else
      user = create(:user, :for_mailer_preview)
      work = create(:work, authors: [user.default_pseud])
    end
    UserMailer.delete_work_notification(user, work, user)
  end

  # Sent to a user when their co-creator deletes a work
  # URL: /rails/mailers/user_mailer/delete_work_notification_co_creator?work_id=2
  def delete_work_notification_co_creator
    if params[:work_id]
      work = Work.find_by(id: params[:work_id])
      first_creator = work.users.first
      second_creator = if work.users.count > 1
                         work.users.second
                       else
                         create(:user, login: "PlaceholderCoCreator#{Faker::Alphanumeric.alpha(number: 8)}")
                       end
    else
      first_creator = create(:user, :for_mailer_preview)
      second_creator = create(:user, :for_mailer_preview)
      work = create(:work, authors: [first_creator.default_pseud, second_creator.default_pseud])
    end
    UserMailer.delete_work_notification(first_creator, work, second_creator)
  end

  # URL: /rails/mailers/user_mailer/related_work_notification?creator_count=2
  def related_work_notification
    creator_count = params[:creator_count] ? params[:creator_count].to_i : 1
    user = create(:user, :for_mailer_preview)
    parent_work = create(:work, authors: [user.default_pseud], title: "Inspiration")
    child_work_pseuds = create_list(:user, creator_count).map(&:default_pseud)
    child_work = create(:work, authors: child_work_pseuds)
    related_work = create(:related_work, parent_id: parent_work.id, work_id: child_work.id)
    UserMailer.related_work_notification(user.id, related_work.id)
  end

  # URL: /rails/mailers/user_mailer/related_work_notification_anon
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
