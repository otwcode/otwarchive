require 'spec_helper'

describe CommentMailer do
  describe "basic comment emails" do

    before(:each) do
      @comment = Factory.create(:comment)
    end

    let(:email) { CommentMailer.comment_sent_notification(@comment.id).deliver }

    it "should have a valid from line" do
      text = "From: Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"
      email.encoded.should =~ /#{text}/
    end
  end
end