class UserMailerPreview < ApplicationMailerPreview
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

  # /rails/mailers/user_mailer/work_subscription?work_id=123
  # Preview a subscription notifictation for a work. Replace 123 with the id of
  # any work on your environment. This will generate a subscription notification
  # for all but the first chapter of the work, e.g., a 3-chapter work will have
  # 2 chapters listed in the email. For 1-chapter works, it will use the sole
  # chapter.
  def work_subscription
    work = params[:work_id].present? ? Work.find_by(id: params[:work_id]) : create(:work)
    subscription = create(:subscription, subscribable: work)
    chapter_ids = work.chapter_ids.drop(1).size.zero? ? work.chapter_ids : work.chapter_ids.drop(1)
    entries = []

    chapter_ids.each { |id| entries << "Chapter_#{id}" }
    UserMailer.batch_subscription_notification(subscription.id, entries.to_json)
  end

  # /rails/mailers/user_mailer/user_subscription?user=NAME&work_ids[]=2&work_ids[]=3&chapter_ids[]=8
  # Preview a subscription notification for a user, which can contain chapters
  # and/or works. You can specify the user and the works and/or chapters or
  # we'll make a user, two works, and two chapters.
  def user_subscription
    if params[:user] && (params[:work_ids] || params[:chapter_ids])
      user = User.find_by(login: params[:user])
      work_ids = params[:work_ids] || []
      chapter_ids = params[:chapter_ids] || []
    else
      user = create(:user)
      first_work = create(:work, authors: [user.default_pseud], title: "First New Work")
      second_work = create(:work, authors: [user.default_pseud], title: "Second New Work",  expected_number_of_chapters: nil, backdate: true)
      third_work = create(:work, authors: [user.default_pseud], title: "Existing Work",  expected_number_of_chapters: 9)
      first_chapter = create(:chapter, work: second_work, authors: [user.default_pseud], position: 2)
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

  private

  def creatorship_notification_data
    first_creator = create(:user, login: "JayceHexmaster")
    second_creator = create(:user, login: "viktor_the_machine")
    work = create(:work, authors: [first_creator.default_pseud, second_creator.default_pseud])
    second_creatorship = Creatorship.find_by(creation: work, pseud: second_creator.default_pseud)
    [second_creatorship, first_creator]
  end
end
