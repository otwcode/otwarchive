require 'spec_helper'

describe CommentMailer do
  describe "basic comment emails" do

    before(:each) do
      @comment = FactoryGirl.create(:comment)
    end

    let(:email) { CommentMailer.comment_sent_notification(@comment.id).deliver }

    it "should have a valid from line" do
      text = "From: Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      expect(email.encoded).to match(/#{text}/)
    end
  end
end
