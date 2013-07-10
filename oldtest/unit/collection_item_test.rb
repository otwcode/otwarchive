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
  
  context "a closed collection" do
    setup do
      @collection = create_collection
      @collection.collection_preference.closed = true
      @collection.save
      @collection_item = CollectionItem.new(:collection => @collection, :item => create_work)
    end
    should "not allow new items" do
      assert !@collection_item.valid?
      assert @collection_item.errors[:base].match(/currently closed/)
    end
  end
    
  context "a collection item in an unmoderated collection" do
    setup do
      @collection_item = create_collection_item
    end
    should "be approved by the collection" do
      assert @collection_item.approved_by_collection?
    end
    should "not be approved or rejected by the user" do
      assert !@collection_item.approved_by_user?
      assert !@collection_item.rejected_by_user?
    end
    context "posted by the user" do
      setup do
        user = create_user
        User.current_user = user
        work = create_work(:authors => [user.default_pseud])
        @collection_item = create_collection_item(:item => work)
        # unset this for future tests
        User.current_user = nil
      end
      should "be approved by the collection" do
        assert @collection_item.approved_by_collection?
      end
      should "be approved by the user" do
        assert @collection_item.approved_by_user?
      end
    end
  end
  
  context "a collection item in a moderated collection" do
    setup do
      @collection = create_collection
      @collection.collection_preference.moderated = true
      @collection.save
      @collection_item = CollectionItem.new(:collection => @collection, :item => create_work)
    end
    should "not be approved or rejected by the collection" do
      assert !@collection_item.approved_by_collection?
      assert !@collection_item.rejected_by_collection?
    end
    should "not be approved or rejected by the user" do
      assert !@collection_item.approved_by_user?
      assert !@collection_item.rejected_by_user?
    end
    context "posted by a moderator" do
      setup do
        user = create_user
        User.current_user = user
        @mod = create_collection_participant(:collection => @collection, :pseud => user.default_pseud, :participant_role => CollectionParticipant::MODERATOR)
        @collection.reload

        @collection_item = create_collection_item(:collection => @collection)
        User.current_user = nil
      end
      should "be approved by the collection" do
        assert @collection_item.approved_by_collection?
      end
      should "not be approved or rejected by the user" do
        assert !@collection_item.approved_by_user?
        assert !@collection_item.rejected_by_user?
      end
    end
  end
    
end
