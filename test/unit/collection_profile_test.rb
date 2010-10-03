require 'test_helper'

class CollectionProfileTest < ActiveSupport::TestCase
  context "a collection profile" do
    setup do
      assert create_collection_profile
    end
    should_belong_to :collection
    should_ensure_length_in_range :intro, 0..ArchiveConfig.INFO_MAX, :long_message => /must be less/
    should_ensure_length_in_range :faq, 0..ArchiveConfig.INFO_MAX, :long_message => /must be less/
    should_ensure_length_in_range :rules, 0..ArchiveConfig.INFO_MAX, :long_message => /must be less/
  end
end
