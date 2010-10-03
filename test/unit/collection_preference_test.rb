require 'test_helper'

class CollectionPreferenceTest < ActiveSupport::TestCase
  context "a collection preference" do
    setup do
      assert create_collection_preference
    end
    should_belong_to :collection
    should "be unmoderated and open" do
      @cpref = create_collection_preference
      assert !@cpref.closed
      assert !@cpref.moderated
    end
    
  end
end
