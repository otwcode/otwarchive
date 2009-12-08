require 'test_helper'

class CollectionItemTest < ActiveSupport::TestCase
  context "a collection item" do
    setup do
      assert create_collection_item
    end
    should_belong_to :collection
    should_belong_to :item
    should_allow_values_for :user_approval_status, 0, 1, -1
    should_not_allow_values_for :user_approval_status, 4, 11, "hello"
    should_allow_values_for :collection_approval_status, 0, 1, -1
    should_not_allow_values_for :collection_approval_status, 4, 11, "hello"
  end
    
end
