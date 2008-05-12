require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  def test_validity
    comment = Comment.new({:content => 'foo', :name => 'Someone', :email => 'someone@someplace.org'})
    assert comment.valid?
    
    comment = Comment.new()
    assert !comment.valid?
  end
  
  def test_max_thread
    assert_equal(666, Comment.max_thread)
  end
  
  def test_reply_comment
     assert !comments(:basic_comment).reply_comment?
     assert comments(:comment_on_comment).reply_comment?
  end
  
  def test_set_depth
     comment = comments(:basic_comment)
     comment.set_depth
     assert_equal(0, comment.depth)
     
     reply_comment = comments(:comment_on_comment)
     reply_comment.set_depth
     assert_equal(1, reply_comment.depth)     
  end 
  
  def test_children_count
     assert_equal(1, comments(:basic_comment).children_count)
     assert_equal(0, comments(:comment_on_comment).children_count)
  end
  
end
