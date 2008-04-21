require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end 
  
  fixtures :comments
  
  def test_max_thread
    assert_equal(666, Comment.max_thread)
  end
  
  def test_reply_comment
     assert !comments(:comment1).reply_comment?
     assert comments(:reply_comment1).reply_comment?
  end
  
  def test_set_depth
     comment = comments(:comment1)
     comment.set_depth
     assert_equal(0, comment.depth)
     
     reply_comment = comments(:reply_comment1)
     reply_comment.set_depth
     assert_equal(1, reply_comment.depth)     
  end 
  
  def test_children_count
     assert_equal(1, comments(:comment1).children_count)
     assert_equal(0, comments(:reply_comment1).children_count)
  end
  
end
