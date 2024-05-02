require "spec_helper"

describe CommentMailer do
  let(:comment) { create(:comment) }
  let(:user) { create(:user) }

  shared_examples "it retries when the comment doesn't exist" do
    it "tries to send the email 3 times, then fails silently" do
      comment.delete

      assert_performed_jobs 3, only: ApplicationMailerJob do
        subject.deliver_later
      end
    end
  end

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

  shared_examples "a notification email with a link to the comment's thread" do
    describe "HTML email" do
      it "has a link to the comment's thread" do
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{comment_url(comment.thread)}\"]",
          text: "Go to the thread to which this comment belongs"
        )
      end
    end

    describe "text email" do
      it "has a link to the comment's thread" do
        expect(subject).to have_text_part_content(
          "Go to the thread to which this comment belongs: #{comment_url(comment.thread)}"
        )
      end
    end
  end

  shared_examples "a comment subject to image safety mode settings" do
    let(:image_url) { "an_image.png" }
    let(:image_tag) { "<img src=\"#{image_url}\" />" }
    let(:all_parent_types) { %w[AdminPost Chapter Tag] }
    let(:comment_parent_type) { [comment.parent_type] }

    before do
      comment.comment_content += image_tag
      comment.save!
    end

    context "when image safety mode is enabled for the parent type" do
      before { allow(ArchiveConfig).to receive(:PARENTS_WITH_IMAGE_SAFETY_MODE).and_return(comment_parent_type) }

      it "strips the image from the email message but leaves its URL" do
        expect(email).not_to have_html_part_content(image_tag)
        expect(email).not_to have_text_part_content(image_tag)
        expect(email).to have_html_part_content(image_url)
        expect(email).to have_text_part_content(image_url)
      end
    end

    context "when image safety mode is not enabled for the parent type" do
      it "embeds the image in the HTML email when image safety mode is completely disabled" do
        allow(ArchiveConfig).to receive(:PARENTS_WITH_IMAGE_SAFETY_MODE).and_return([])
        expect(email).to have_html_part_content(image_tag)
        expect(email).not_to have_text_part_content(image_url)
      end

      it "embeds the image in the HTML email when image safety mode is enabled for other parent types" do
        allow(ArchiveConfig).to receive(:PARENTS_WITH_IMAGE_SAFETY_MODE).and_return(all_parent_types - comment_parent_type)
        expect(email).to have_html_part_content(image_tag)
        expect(email).not_to have_text_part_content(image_url)
      end
    end
  end

  describe "#comment_notification" do
    subject(:email) { CommentMailer.comment_notification(user, comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is on an admin post" do
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is a reply to another comment" do
      let(:comment) { create(:comment, commentable: create(:comment)) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a comment subject to image safety mode settings"

      context "when the comment is a reply to another comment" do
        let(:comment) { create(:comment, commentable: create(:comment, :on_tag)) }

        it_behaves_like "a notification email with a link to the comment"
        it_behaves_like "a notification email with a link to reply to the comment"
        it_behaves_like "a notification email with a link to the comment's thread"
        it_behaves_like "a comment subject to image safety mode settings"
      end
    end
  end

  describe "edited_comment_notification" do
    subject(:email) { CommentMailer.edited_comment_notification(user, comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is on an admin post" do
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is a reply to another comment" do
      let(:comment) { create(:comment, commentable: create(:comment)) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a comment subject to image safety mode settings"

      context "when the comment is a reply to another comment" do
        let(:comment) { create(:comment, commentable: create(:comment, :on_tag)) }

        it_behaves_like "a notification email with a link to the comment"
        it_behaves_like "a notification email with a link to reply to the comment"
        it_behaves_like "a notification email with a link to the comment's thread"
        it_behaves_like "a comment subject to image safety mode settings"
      end
    end
  end

  describe "comment_reply_notification" do
    subject(:email) { CommentMailer.comment_reply_notification(parent_comment, comment) }

    let(:parent_comment) { create(:comment) }
    let(:comment) { create(:comment, commentable: parent_comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a notification email with a link to the comment's thread"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is on an admin post" do
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is from a user using a banned email" do
      before { create(:admin_blacklisted_email, email: parent_comment.comment_owner_email) }

      # Don't consider banned emails for registered users.
      it_behaves_like "a notification email with a link to the comment"
    end

    context "when the comment is from a guest using a banned email" do
      let(:parent_comment) { create(:comment, :by_guest) }

      before { create(:admin_blacklisted_email, email: parent_comment.comment_owner_email) }

      it_behaves_like "an unsent email"
    end
  end

  describe "edited_comment_reply_notification" do
    subject(:email) { CommentMailer.edited_comment_reply_notification(parent_comment, comment) }

    let(:parent_comment) { create(:comment) }
    let(:comment) { create(:comment, commentable: parent_comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a notification email with a link to the comment's thread"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is on an admin post" do
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is from a user using a banned email" do
      before { create(:admin_blacklisted_email, email: parent_comment.comment_owner_email) }

      # Don't consider banned emails for registered users.
      it_behaves_like "a notification email with a link to the comment"
    end

    context "when the comment is from a guest using a banned email" do
      let(:parent_comment) { create(:comment, :by_guest) }

      before { create(:admin_blacklisted_email, email: parent_comment.comment_owner_email) }

      it_behaves_like "an unsent email"
    end
  end

  describe "comment_sent_notification" do
    subject(:email) { CommentMailer.comment_sent_notification(comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is on an admin post" do
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a comment subject to image safety mode settings"
    end
  end

  describe "comment_reply_sent_notification" do
    subject(:email) { CommentMailer.comment_reply_sent_notification(comment) }

    let(:parent_comment) { create(:comment) }
    let(:comment) { create(:comment, commentable: parent_comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to the comment's thread"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is on an admin post" do
      let(:parent_comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the parent comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a comment subject to image safety mode settings"
    end
  end
end
