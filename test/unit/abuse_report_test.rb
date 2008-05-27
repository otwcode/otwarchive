require File.dirname(__FILE__) + '/../test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  # Test validations
  def test_validations_fail
    # validates_presence_of :comment
    report = new_abuse_report(:comment => "")
    assert !report.save
    # validates_email_veracity_of :email
    report = new_abuse_report(:email => "user@domain.badbadbad")
    assert !report.save
    # validates_format_of :url, :with => app_url_regex
    report = new_abuse_report(:url => random_url)
    assert !report.save
    report = new_abuse_report(:url => "badly formed" + ArchiveConfig.APP_URL)
    assert !report.save
    report = new_abuse_report(:url => "")
    assert !report.save
  end
  def test_validations_pass
    # test example_data.rb
    assert create_abuse_report
    # validates_email_veracity_of :email, :allow_blank => true
    assert create_abuse_report(:email => "")
    # minimal url
    assert create_abuse_report(:url => ArchiveConfig.APP_URL)
  end
end
