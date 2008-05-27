require File.dirname(__FILE__) + '/../test_helper'
  
class CommentTest < ActiveSupport::TestCase
  # Test validations
  def test_validations
    # test example_data.rb
    assert new_comment.set_and_save
    # validates_presence_of :content
    assert !new_comment(:content => "").set_and_save
    # validates_presence_of :name, :email, :unless => :pseud_id
    assert !new_comment(:email => "").set_and_save
    assert !new_comment(:name => "").set_and_save
    assert new_comment(:pseud_id => create_user.default_pseud.id, :email => '', :name => '').set_and_save
  end
  
  # Test associations
  # belongs_to :pseud
  def test_belongs_to_pseud
    pseud = create_pseud
    comment = new_comment(:pseud_id => pseud.id)
    comment.set_and_save
    assert_equal pseud, comment.pseud
  end  
  # belongs_to :commentable, :polymorphic => true
  def test_belongs_to_commentable
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    comment = new_comment(:commentable_id => chapter.id)
    assert_equal chapter, comment.commentable
  end
  
  # Test acts_as
  # acts_as_commentable: CommentableEntity methods find_all_comments & count_all_comments
  def test_commentable_entity
    comment = new_comment
    comment.set_and_save
    child = new_comment(:commentable_type => 'Comment', :commentable_id => comment.id)
    child.set_and_save
    grandchild = new_comment(:commentable_type => 'Comment', :commentable_id => child.id)
    grandchild.set_and_save
    assert_equal [child, grandchild], comment.find_all_comments
    assert_equal 2, comment.count_all_comments
  end
  # has_comment_methods: set_and_save, destroy_or_mark_deleted, full_set
  # TODO test rest of comment methods, if used
  def test_set_and_save
    # set_and_save sets the depth, the thread, and adds as a child if it's a reply to a comment
    comment = new_comment
    comment.set_and_save
    assert_equal 0, comment.depth
    child = new_comment(:commentable_type => 'Comment', :commentable_id => comment.id)
    child.set_and_save
    assert_equal 1, child.depth
    assert_equal comment.thread, child.thread
    assert Comment.find(comment.id).all_children.include?(child)
    # TODO more tests for depth and add_child under different circumstances
  end  
  def test_destroy_or_mark_deleted
    # a comment with a child gets marked is_deleted
    comment = new_comment
    comment.set_and_save
    # give it a child
    child = new_comment(:commentable_type => 'Comment', :commentable_id => comment.id)
    child.set_and_save  
    comment = Comment.find(comment.id)
    comment.destroy_or_mark_deleted
    assert comment = Comment.find(comment.id)
    assert comment.is_deleted
    
    # another comment with no children gets destroyed
    another_comment = new_comment
    another_comment.set_and_save    
    another_comment = Comment.find(another_comment.id)
    another_comment.destroy_or_mark_deleted
    assert_raises(ActiveRecord::RecordNotFound) { Comment.find(another_comment.id) }
  end
    
  def test_full_set
    # Returns all sub-comments plus the comment itself
    comment = new_comment
    comment.set_and_save
    comment = Comment.find(comment.id)
    assert_equal [comment], comment.full_set
    child = new_comment(:commentable_type=>'Comment', :commentable_id=> comment.id)
    child.set_and_save    
    comment = Comment.find(comment.id)
    assert_equal [comment, child], comment.full_set
  end

  # Test before and after
  # before_create :check_for_spam

  def test_check_for_spam
    comment = new_comment(:pseud_id => create_pseud)
    assert_nil comment.approved
    assert comment.check_for_spam  # should always return true
    assert comment.approved 
    # TODO - test for actual spam
  end
  
  # Test methods
  # FIXME didn't create tests for akismet_attributes, because they could/should be private
  def test_mark_as_spam
    comment = create_comment
    assert comment.mark_as_spam!
    assert !comment.approved    
    # TODO - what happens if a signed comment is marked as spam? can it even be done?
  end
  def test_mark_as_ham
    comment = create_comment
    comment.mark_as_spam!
    comment.mark_as_ham!
    assert comment.approved
  end
end
