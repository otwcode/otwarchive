require 'test_helper'

class InboxCommentTest < ActiveSupport::TestCase
  
  context "An Inbox Comment" do
    setup do
      @user = create_user
      @comment = create_comment(:pseud_id => @user.default_pseud.id)
      @myinbox_comment = create_inbox_comment(:user_id => @user.id, :feedback_comment_id => @comment.id)
    end
    should_belong_to :user
    should_belong_to :feedback_comment
    should_validate_presence_of :user_id
    should_validate_presence_of :feedback_comment_id
    
    context "which is marked read" do
      should "change the count_unread total" do
        assert_difference('InboxComment.count_unread', -1) do 
          @myinbox_comment.update_attribute(:read, true)
        end
      end     
    end
    
    context "which has had its feedback comment deleted" do
      setup do
        @myinbox_comment.feedback_comment.destroy
      end
      should "also be deleted" do
        assert_raises(ActiveRecord::RecordNotFound) { @myinbox_comment.reload }
      end
    end
    
    context "which belonged to a deleted user" do
      setup do
        @myinbox_comment.user.destroy
      end
      should "also be deleted" do
        assert_raises(ActiveRecord::RecordNotFound) { @myinbox_comment.reload }
      end
    end

    # test find by filters?
    
  end
  
end
