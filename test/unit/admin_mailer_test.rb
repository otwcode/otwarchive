require File.dirname(__FILE__) + '/../test_helper'

class AdminMailerTest < ActionMailer::TestCase
  tests AdminMailer
  def test_abuse_report_header
    url = reporter = comment = ""
    mail = AdminMailer.create_abuse_report(reporter, url, comment)

    assert_equal ['do-not-reply@test.com'], mail.from
    assert_equal ['abuse@test.com'], mail.to
    assert_equal "Test Archive - Admin Abuse Report", mail.subject
  end
  def test_abuse_report_body
    url = "http://localhost:3001/en/works/2"
    reporter = "test@test.com"
    comment = "work 2 is abusive"
    mail = AdminMailer.create_abuse_report(reporter, url, comment)

    assert_match /test@test.com/, mail.body 
    assert_match /en\/works\/2/, mail.body
    assert_match /work 2 is abusive/, mail.body
  end
end
