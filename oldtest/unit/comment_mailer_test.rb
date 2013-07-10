require 'test_helper'

class CommentMailerTest < ActionMailer::TestCase

  def test_comment_notification
    pseud1 = create_pseud
    chapter1 = new_chapter
    work = create_work(:chapters => [chapter1], :authors => [pseud1])
    comment = create_comment(:commentable_id => chapter1.id)
    mail = CommentMailer.create_comment_notification(pseud1.user, comment)
    assert_match 'New comment on ', mail.subject
    assert_match comment.content, mail.body
    assert_equal [pseud1.user.email], mail.to
  end
  def test_comment_reply_notification
    email1 = "test@foo.com"
    email2 = "test@bar.com"
    comment1 = create_comment(:email => email1, :pseud=>nil, :name=>'Test Foo')
    comment2 = create_comment(:commentable_id => comment1.id, :commentable_type => 'Comment', 
                              :email => email2, :name => 'Test Bar')
    mail = CommentMailer.create_comment_reply_notification(comment1, comment2)
    assert_match 'Reply to your comment on ', mail.subject
    assert_match comment2.content, mail.body
    assert_equal [email1], mail.to    
  end
  def test_comment_sent_notification
    email = "test@example.com"
    comment = create_comment(:email => email, :pseud=>nil, :name=>'Test Foo')
    mail = CommentMailer.create_comment_sent_notification(comment)
    assert_match 'Comment you sent on ', mail.subject
    assert_match comment.content, mail.body
    assert_equal [email], mail.to 
  end
end

