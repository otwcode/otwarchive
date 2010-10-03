require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase
  should "setup email" do
    mail = AdminMailer.create_abuse_report("", "", "")

    assert_equal [ArchiveConfig.RETURN_ADDRESS], mail.from
    assert_equal [ArchiveConfig.ABUSE_ADDRESS], mail.to
    assert_equal ArchiveConfig.APP_NAME + " - Admin Abuse Report", mail.subject
  end

  should "send abuse report" do
    email = random_email
    url = random_url(ArchiveConfig.APP_URL)
    comment = random_phrase

    mail = AdminMailer.create_abuse_report(email, url, comment)

    assert_match Regexp.new(email), mail.body
    assert_match Regexp.new(url), mail.body
    assert_match Regexp.new(comment), mail.body  
  end

  should "send feedback" do
    feedback = create_feedback

    mail = AdminMailer.create_feedback(feedback)

    assert_match Regexp.new(feedback.comment), mail.body
    assert_match Regexp.new(ArchiveConfig.REVISION), mail.body
    assert_equal ArchiveConfig.APP_NAME + ": Support - " + feedback.summary, mail.subject
    assert_equal [ArchiveConfig.RETURN_ADDRESS], mail.from
    assert_equal [ArchiveConfig.FEEDBACK_ADDRESS], mail.to    
  end
end
