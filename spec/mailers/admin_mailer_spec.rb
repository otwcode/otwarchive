require 'spec_helper'

describe AdminMailer do
  describe "basic admin emails" do

    before(:each) do
      @user = User.new
      @user.login = "myname"
      @user.age_over_13 = "1"
      @user.terms_of_service = "1"
      @user.email = "foo1@archiveofourown.org"
      @user.password = "password"
      @user.activate
      @admin = Admin.new
      @subject = "A Message For You"
      @message = "This is a fancy message"
    end

    let(:email) { UserMailer.archive_notification(@admin, @user, @subject, @message).deliver }

    it "should have a valid from line" do
      text = "From: Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.encoded).to match(/#{text}/)
    end
  end
end