require File.dirname(__FILE__) + '/../test_helper'

class AdminMailerTest < ActionMailer::TestCase
  tests AdminMailer
  def test_new_admin_mailer_abuse_report
    reporter = random_email
    url = random_url(ArchiveConfig.APP_URL)
    comment = random_phrase
    mail = AdminMailer.create_abuse_report(reporter, url, comment)

    assert_equal [ArchiveConfig.RETURN_ADDRESS], mail.from
    assert_equal [ArchiveConfig.ABUSE_ADDRESS], mail.to
    assert_equal ArchiveConfig.APP_NAME + " - Admin Abuse Report", mail.subject
    assert_match Regexp.new(reporter), mail.body
    assert_match Regexp.new(url), mail.body 
    assert_match Regexp.new(comment), mail.body
  end
end
