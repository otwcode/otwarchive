require 'test_helper'

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

end

