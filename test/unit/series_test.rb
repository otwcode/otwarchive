require 'test_helper'

class SeriesTest < ActiveSupport::TestCase

  context "a series" do
    setup do
      assert create_series       
    end
    should_have_many :serial_works, :works, :bookmarks
    should_validate_presence_of :title
    should_ensure_length_in_range :title, ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX, :short_message => /must be at least/, :long_message => /must be less/
    should_ensure_length_in_range :summary, 0..ArchiveConfig.SUMMARY_MAX, :long_message => /must be less/
    should_ensure_length_in_range :notes, 0..ArchiveConfig.NOTES_MAX, :long_message => /must be less/

  end

  

end
