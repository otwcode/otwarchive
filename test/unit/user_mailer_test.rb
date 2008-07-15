require File.dirname(__FILE__) + '/../test_helper'

class UserMailerTest < ActionMailer::TestCase
  # Test methods
  def test_signup_notification
    user = create_user
    mail = UserMailer.create_signup_notification(user)    
    assert_match 'activate', mail.subject
    assert_match 'Welcome', mail.body
    assert_match Regexp.new(user.activation_code), mail.body 
    assert_equal [user.email], mail.to
  end
  def test_activation
    user = create_user
    mail = UserMailer.create_activation(user)
    assert_match 'activated!', mail.body
    assert_match ArchiveConfig.APP_URL, mail.body 
    assert_equal [user.email], mail.to
  end
  def test_reset_password
    user = create_user
    mail = UserMailer.create_reset_password(user)
    assert_match 'Password reset', mail.subject
    assert_match 'has been reset', mail.body
    assert_match user.password, mail.body 
    assert_equal [user.email], mail.to
  end
  def test_feedback_notification
    user = create_user
    comment = create_comment(:pseud_id => create_pseud)
    mail = UserMailer.create_feedback_notification(user, comment)
    assert_match 'New Feedback', mail.subject
    assert_match comment.content, mail.body
    assert_equal [user.email], mail.to    
  end
end
