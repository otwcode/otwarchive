require File.dirname(__FILE__) + '/../test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  def test_good_reports
    assert AbuseReport.new(:email => "test@test.com", 
			:url => "http://www.test.com",
			:comment => "minimum url")
    assert AbuseReport.new(:email => "",
			:url => "http://www.test.com/en/work/1",
			:comment => "anonymous report is okay")
  end
  def test_bad_reports
    assert !AbuseReport.new(:email => "nocomment@test.com",
			:url => "http://www.test.com",
			:comment => "").save
    assert !AbuseReport.new(:email => "test@test.com", 
			:url => "",
			:comment => "No Url").save
    assert !AbuseReport.new(:email => "test@test.com", 
			:url => "http://www.google.com",
			:comment => "Not my Url").save
    assert !AbuseReport.new(:email => "not an email address",
			:url => "http://www.test.com",
			:comment => "email, but not valid").save
  end
end
