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

  def challenge_assignment_notification_any
    assignment = create(:challenge_assignment)

    signup = assignment.request_signup
    signup.pseud = create(:user, :for_mailer_preview).default_pseud
    signup.save!

    # Fill all tag fields with "Any"
    prompt = signup.requests.first
    TagSet::TAG_TYPES.each do |type|
      prompt.send(:"any_#{type}=", true)
    end
    prompt.title = "This is a title"
    prompt.save!

    UserMailer.challenge_assignment_notification(assignment.collection.id, assignment.offering_user.id, assignment.id)
  end

  def challenge_assignment_notification_filled
    assignment = create(:challenge_assignment)

    signup = assignment.request_signup
    signup.pseud = create(:user, :for_mailer_preview).default_pseud
    signup.save!

    challenge = assignment.collection.challenge
    challenge.assignments_due_at = params[:due] ? params[:due].to_time : Time.current
    challenge.save!

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
    %w(fandom character relationship freeform).each do |type|
      tag_set.tags += [create(:"canonical_#{type}"), create(:"canonical_#{type}"), create(:"canonical_#{type}")]
    end
    tag_set.save!

    prompt = signup.requests.first
    prompt.tag_set = tag_set
    prompt.title = "This is a title"
    prompt.url = "https://example.com/"
    prompt.optional_tag_set = create(:tag_set, tags: [create(:freeform), create(:freeform), create(:freeform)])
    prompt.save!

    UserMailer.challenge_assignment_notification(assignment.collection.id, assignment.offering_user.id, assignment.id)
  end

  def claim_notification_registered
    work = create(:work)
    creator_id = work.pseuds.first.user.id
    UserMailer.claim_notification(creator_id, [work.id], true)
  end

  private

  def creatorship_notification_data(creation_type)
    first_creator = create(:user, :for_mailer_preview)
    second_creator = create(:user, :for_mailer_preview)
    creation = create(creation_type, authors: [first_creator.default_pseud, second_creator.default_pseud])
    [creation.creatorships.last, first_creator]
  end
end
