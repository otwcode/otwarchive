require File.dirname(__FILE__) + '/../test_helper'

class UserMailerTest < ActionMailer::TestCase
  # Test methods
  context "For a specified user" do
    setup do
      @user = create_user
    end  
  
    should "send a sign-up notification" do
      mail = UserMailer.create_signup_notification(@user)
      assert_match 'activate', mail.subject
      assert_match 'Welcome', mail.body
      assert_match Regexp.new(@user.activation_code), mail.body 
      assert_equal [@user.email], mail.to    
    end
  
    should "send an activation confirmation" do
      mail = UserMailer.create_activation(@user)
      assert_match 'activated', mail.subject      
      assert_match 'activated!', mail.body
      assert_match ArchiveConfig.APP_URL, mail.body 
      assert_equal [@user.email], mail.to
    end
    
    should "send a password reset email" do
      mail = UserMailer.create_reset_password(@user)
      assert_match 'Password reset', mail.subject
      assert_match 'has been reset', mail.body
      assert_match @user.password, mail.body 
      assert_equal [@user.email], mail.to
    end
    
    should "send an archive notification" do
      admin = create_admin
      subject = random_phrase
      message = random_paragraph
      mail = UserMailer.create_archive_notification(admin, @user, subject, message)
      assert_match 'Admin Message', mail.subject
      assert_match message, mail.body
     # assert_match admin.login, mail.body (we just have admin in the model, is that correct?)
      assert_equal [@user.email], mail.to
    end
  end


  def test_comment_notification
    pseud1 = create_pseud
    chapter1 = new_chapter
    work = create_work(:chapters => [chapter1], :authors => [pseud1])
    comment = create_comment(:commentable_id => chapter1.id)
    mail = UserMailer.create_comment_notification(pseud1.user, comment)
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
    mail = UserMailer.create_comment_reply_notification(comment1, comment2)
    assert_match 'Reply to your comment on ', mail.subject
    assert_match comment2.content, mail.body
    assert_equal [email1], mail.to    
  end
  def test_comment_sent_notification
    email = "test@foo.com"
    comment = create_comment(:email => email, :pseud=>nil, :name=>'Test Foo')
    mail = UserMailer.create_comment_sent_notification(comment)
    assert_match 'Comment you sent on ', mail.subject
    assert_match comment.content, mail.body
    assert_equal [email], mail.to 
  end
end

