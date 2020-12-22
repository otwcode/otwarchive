require "spec_helper"

describe CommentMailer do
  let(:comment) { create(:comment) }
  let(:user) { create(:user) }

  shared_examples "a notification email with a link to the comment" do
    describe "HTML email" do
      it "has a link to the comment" do
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{comment_url(comment)}\"]",
          text: "Go to the thread starting from this comment"
        )
      end
    end

    describe "text email" do
      it "has a link to the comment" do
        expect(subject).to have_text_part_content(
          "Go to the thread starting from this comment: #{comment_url(comment)}"
        )
      end
    end
  end

  shared_examples "a notification email with a link to reply to the comment" do
    describe "HTML email" do
      it "has a link to reply to the comment" do
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{comment_url(comment, add_comment_reply_id: comment.id)}\"]",
          text: "Reply to this comment"
        )
      end
    end

    describe "text email" do
      it "has a link to reply to the comment" do
        expect(subject).to have_text_part_content(
          "Reply to this comment: #{comment_url(comment, add_comment_reply_id: comment.id)}"
        )
      end
    end
  end

  describe "comment_notification" do
    subject(:email) { CommentMailer.comment_notification(user, comment).deliver }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
    end
  end

  describe "edited_comment_notification" do
    subject(:email) { CommentMailer.edited_comment_notification(user, comment).deliver }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
    end
  end

  describe "comment_reply_notification" do
    subject(:email) { CommentMailer.comment_reply_notification(parent_comment, comment).deliver }

    let(:parent_comment) { create(:comment) }
    let(:comment) { create(:comment, commentable: parent_comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
    end
  end

  describe "edited_comment_reply_notification" do
    subject(:email) { CommentMailer.edited_comment_reply_notification(parent_comment, comment).deliver }

    let(:parent_comment) { create(:comment) }
    let(:comment) { create(:comment, commentable: parent_comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
    end
  end

  describe "comment_sent_notification" do
    subject(:email) { CommentMailer.comment_sent_notification(comment).deliver }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a notification email with a link to the comment"

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
    end
  end
end
