require 'test_helper'

class CollectionPreferenceTest < ActiveSupport::TestCase
  context "a collection preference" do
    setup do
      assert create_collection_preference
    end
    should_belong_to :collection
    should_allow_values_for :allowed_to_post, 1,2,3,4
    should_not_allow_values_for :allowed_to_post, 0, 14, -2, "hello"
  end
end
