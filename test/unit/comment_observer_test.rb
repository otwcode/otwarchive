require File.dirname(__FILE__) + '/../test_helper'

class CommentObserverTest < Test::Unit::TestCase
  context "A comment on a Work by one person" do
    setup do
      @user = create_user
      chapter = new_chapter(:authors => [@user.default_pseud])
      work = create_work(:chapters => [new_chapter], :authors => [@user.default_pseud])
      @comment = new_comment(:commentable => work)    
    end
    should "get one feedback" do
      assert_difference('InboxComment.count') do
        @comment.save
      end
    end
  end
  context "A comment on a Work by two people" do
    setup do
      @user1 = create_user
      @user2 = create_user
      chapter = new_chapter(:authors => [@user1.default_pseud])
      work = create_work(:chapters => [new_chapter], :authors => [@user1.default_pseud, @user2.default_pseud])
      @comment = new_comment(:commentable => work)    
    end
    should "get two feedbacks" do
      assert_difference('InboxComment.count', 2) do
        @comment.save
      end
    end
  end
end
