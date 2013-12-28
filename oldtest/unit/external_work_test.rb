require 'test_helper'

class ExternalWorkTest < ActiveSupport::TestCase

  VALID_URLS    = ['http://godaddy.com', 'http://www.godaddy.com','www.godaddy.com', 'godaddy.com' ]
  INVALID_URLS  = ['https://godaddy.com', 'ftp://godaddy.com', 'adfsadfsd', 'localhost', 'http://godaddy.com/" onclick="whee">']

  context "An external work" do
    setup do
      assert create_external_work
    end
    should_validate_presence_of :title
    should_validate_presence_of :author
    should_validate_presence_of :url
    should_ensure_length_in_range :title, (ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX), :long_message => /must be less/, :short_message => /must be at least/
    should_allow_values_for :url, *VALID_URLS
    should_not_allow_values_for :url, *INVALID_URLS
    context "with a summary" do
      setup do
        create_external_work(:summary => random_paragraph)
      end
      should_ensure_length_in_range :summary, (0..ArchiveConfig.SUMMARY_MAX), :long_message => /must be less/
    end
  end

end
