require File.dirname(__FILE__) + '/../test_helper'

class ExternalWorkTest < ActiveSupport::TestCase

  context "An external work" do
    setup do
      @external_work = create_external_work
    end
    should_validate_presence_of :title
    should_validate_presence_of :author
    should_validate_presence_of :url
    should_ensure_length_in_range :title, (ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX), :long_message => /must be less/, :short_message => /must be at least/
    context "with a summary" do
      setup do
      @external_work.summary = random_paragraph
      end
      should_ensure_length_in_range :summary, (0..ArchiveConfig.SUMMARY_MAX), :long_message => /must be less/
    end
  end

end
