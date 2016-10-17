require 'spec_helper'

describe AdminMailer do
  describe "basic admin emails" do
    let(:email) do
      UserMailer.archive_notification(
        Admin.new,
        FactoryGirl.create(:user, :active),
        "A Message For You",
        "This is a fancy message"
      ).deliver
    end

    it "should have a valid from line" do
      text = "From: Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.encoded).to match(/#{text}/)
    end
  end
end