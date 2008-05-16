require File.dirname(__FILE__) + '/../test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  def test_new_default_abuse_report
    assert create_abuse_report
  end
  def test_new_anonymous_abuse_report
    assert create_abuse_report(:email => "")
  end
  def test_new_minimal_url_abuse_report
    assert create_abuse_report(:url => ArchiveConfig.APP_URL)
  end
  def test_new_abuse_reports_without_comment
    report = new_abuse_report(:comment => "")
    assert !report.save
  end
  def test_new_abuse_reports_without_url
    report = new_abuse_report(:url => "")
    assert !report.save
  end
  def test_new_abuse_reports_with_url_outside_of_app
    report = new_abuse_report(:url => random_url)
    assert !report.save
  end
  def test_new_abuse_reports_with_bad_email
    report = new_abuse_report(:email => "user@domain.bad")
    assert !report.save
  end
  def test_new_abuse_reports_with_badly_formed_url
    report = new_abuse_report(:url => "badly formed" + ArchiveConfig.APP_URL)
    assert !report.save
  end
end
