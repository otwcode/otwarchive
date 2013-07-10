require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  context "A comment" do
    setup do
      user = create_user
      @mycomment = create_comment(:pseud_id => user.default_pseud.id)
    end
    should_belong_to :pseud
    should_belong_to :commentable
    should_have_many :users, :through => :inbox_comments
    should_have_many :inbox_comments
    should_validate_presence_of :content
    should_ensure_length_in_range :content, (0..ArchiveConfig.COMMENT_MAX), :long_message => /must be less/

    # acts_as_commentable: CommentableEntity methods find_all_comments & count_all_comments
    context "with its own comment" do
      setup do
        @second_comment = create_comment(:commentable => @mycomment)
      end
      should "find that comment" do
        assert_contains(@mycomment.find_all_comments, @second_comment)
      end
      should "count that comment" do
        assert_equal 1, @mycomment.count_all_comments
      end
    end
  end

  context "A user's comment" do
    setup do
      user = create_user
      work = create_work
      assert @mycomment = Comment.new(:pseud_id => user.default_pseud.id, :commentable => work)
    end
    should "not have an email or name value" do
      assert_equal nil, @mycomment.email
      assert_equal nil, @mycomment.name
    end
  end

  context "A non-user's comment" do
    setup do
      user = create_user
      work = create_work
      assert @mycomment = Comment.new(:email => random_email, :name => random_phrase, :commentable => work)
    end
    should_validate_presence_of :email, :name, :content
    should_not_allow_values_for :email, "abcd", :message => /invalid/
    should_allow_values_for :email, "user@google.com"
    should "not have a pseud" do
      assert_equal nil, @mycomment.pseud_id
    end
  end

  # has_comment_methods: save, destroy_or_mark_deleted, full_set
  # TODO test rest of comment methods, if used
  def test_save
    # save sets the depth, the thread, and adds as a child if it's a reply to a comment
    comment = new_comment
    comment.save
    assert_equal 0, comment.depth
    child = new_comment(:commentable_type => 'Comment', :commentable_id => comment.id)
    child.save
    assert_equal 1, child.depth
    assert_equal comment.thread, child.thread
    assert_contains(Comment.find(comment.id).all_children, child)
    # TODO more tests for depth and add_child under different circumstances
  end
  def test_mark_deleted
    # a comment with a child gets marked is_deleted
    comment = new_comment
    comment.save
    # give it a child
    child = new_comment(:commentable_type => 'Comment', :commentable_id => comment.id)
    child.save
    comment = Comment.find(comment.id)
    comment.destroy_or_mark_deleted
    assert comment = Comment.find(comment.id)
    assert comment.is_deleted
  end
  def test_destroy
    # another comment with no children gets destroyed
    comment = new_comment
    another_comment = new_comment
    another_comment.save
    another_comment.reload
    another_comment.destroy_or_mark_deleted
    assert_raises(ActiveRecord::RecordNotFound) { Comment.find(another_comment.id) }
  end

  def test_full_set
    # Returns all sub-comments plus the comment itself
    comment = new_comment
    comment.save
    comment = Comment.find(comment.id)
    assert_equal [comment], comment.full_set
    child = new_comment(:commentable_type=>'Comment', :commentable_id=> comment.id)
    child.save
    comment = Comment.find(comment.id)
    assert_equal [comment, child], comment.full_set
  end

  # Test before and after
  # before_create :check_for_spam

  def test_spam_commands
    comment = new_comment(:pseud_id => create_pseud)
    assert !comment.approved
    assert comment.check_for_spam?  # will always return true in test
    assert comment.approved
    comment.mark_as_spam!
    assert !comment.approved
    comment.mark_as_ham!
    assert comment.approved
  end
end
