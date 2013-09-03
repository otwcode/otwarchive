require 'test_helper'

class CommentObserverTest < ActiveSupport::TestCase
  context "A comment on a Work" do
    setup do
      @work = create_work
      @comment = new_comment(:commentable => @work)    
    end
    should "get feedback" do
      assert_difference('InboxComment.count') do
        @comment.save
      end
    end
    context "by two people" do
      setup do
        @user2 = create_user
        @work.pseuds << @user2.default_pseud
        @comment = new_comment(:commentable => @work)    
      end
      should "get two feedbacks" do
        assert_difference('InboxComment.count', 2) do
          @comment.save
        end
      end
    end
  end
end
