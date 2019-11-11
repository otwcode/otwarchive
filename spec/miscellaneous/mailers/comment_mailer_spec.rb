require 'spec_helper'

describe CommentMailer, type: :mailer do
  describe "basic comment emails" do
    let(:comment) { create(:comment) } 

    subject(:email) { CommentMailer.comment_sent_notification(comment).deliver }

    it_behaves_like "an email with a valid sender"
  end
end
