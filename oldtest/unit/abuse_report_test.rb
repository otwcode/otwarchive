require 'test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  context "An Abuse Report" do
    setup do
      assert create_abuse_report
    end
    should_validate_presence_of :comment
    
    should_not_allow_values_for :email, "abcd", "user@domain.badbadbad", :message => /invalid/
    should_allow_values_for :email, "", "user@google.com"
    
    should_not_allow_values_for :url, "nothing before" + ArchiveConfig.APP_URL, "http://www.google.com/not/our/site", "", :message => /on this site/
    should_allow_values_for :url, ArchiveConfig.APP_URL, ArchiveConfig.APP_URL + "/works"
  end
end
