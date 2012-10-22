require 'test_helper'

class CollectionParticipantTest < ActiveSupport::TestCase
  context "a collection participant" do
    setup do
      assert create_collection_participant
    end
    should_belong_to :collection
    should_belong_to :pseud
    should_allow_values_for :participant_role, "Owner", "Moderator", "Member", "None", "Invited"
    should_not_allow_values_for :participant_role, "Foo", 12, "aldjfa;jfd"
    
    context "who is not a member" do      
      setup do
        @participant = create_collection_participant(:participant_role => CollectionParticipant::NONE)
      end
      should "not be recognized as a member, moderator, or owner" do
        assert @participant.is_none?
        assert !@participant.is_invited?
        assert !@participant.is_member?
        assert !@participant.is_maintainer?
        assert !@participant.is_moderator?
        assert !@participant.is_owner?
      end
      context "after being approved as a member" do
        setup do
          @participant.approve_membership!
          @participant.reload
        end        
        should "be recognized as a member, but not as a moderator, maintainer, or owner" do
          assert !@participant.is_none?
          assert !@participant.is_invited?
          assert @participant.is_member?
          assert !@participant.is_maintainer?
          assert !@participant.is_moderator?
          assert !@participant.is_owner?
        end
      end
    end
  end
end
