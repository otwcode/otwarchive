require File.dirname(__FILE__) + '/../test_helper'

class AbuseReportTest < ActiveSupport::TestCase
  should_require_attributes :comment
  
  should_not_allow_values_for :email, "abcd", "user@domain.badbadbad"
  should_allow_values_for :email, "", "user@google.com"
  
  should_not_allow_values_for :url, "nothing before" + ArchiveConfig.APP_URL, "http://www.google.com/not/our/site", ""
  should_allow_values_for :url, ArchiveConfig.APP_URL, ArchiveConfig.APP_URL + "/en/works"

end
