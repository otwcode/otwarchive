require "spec_helper"

describe CommentMailer do
  let(:user) { create(:user) }
  let(:commenter) { create(:user, login: "Accumulator") }
  let(:commenter_pseud) { create(:pseud, user: commenter, name: "Blueprint") }
  let(:comment) { create(:comment, pseud: commenter_pseud) }

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

  shared_examples "a notification email with the commenters pseud and username" do
    describe "HTML email" do
      it "has the pseud and username of the commenter" do
        expect(email).to have_html_part_content(">Blueprint (Accumulator)</a></b> <em><strong>(Registered User)</strong></em>")
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{user_pseud_url(commenter, commenter_pseud)}\"]",
          text: "Blueprint (Accumulator)"
        )
      end
    end

    describe "text email" do
      it "has the pseud and username of the commenter" do
        expect(subject).to have_text_part_content(
          "Blueprint (Accumulator) (#{user_pseud_url(commenter, commenter_pseud)}) (Registered User)"
        )
      end
    end
  end

  shared_examples "a notification email that marks the commenter as official" do
    describe "HTML email" do
      it "has the username of the commenter and the official role" do
        expect(email).to have_html_part_content(">Centrifuge</a></b> <em><strong>(Official)</strong></em>")
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{user_pseud_url(commenter, commenter.default_pseud)}\"]",
          text: "Centrifuge"
        )
      end
    end

    describe "text email" do
      it "has the username of the commenter and the official role" do
        expect(subject).to have_text_part_content(
          "Centrifuge (#{user_pseud_url(commenter, commenter.default_pseud)}) (Official)"
        )
      end
    end
  end

  describe "comment_notification" do
    subject(:email) { CommentMailer.comment_notification(user, comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a notification email with the commenters pseud and username"

    context "when the comment is by an official user using their default pseud" do
      let(:commenter) { create(:official_user, login: "Centrifuge") }
      let(:comment) { create(:comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email that marks the commenter as official"
    end

    context "when the comment is a reply to another comment" do
      let(:comment) { create(:comment, commentable: create(:comment), pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenters pseud and username"
    end

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with the commenters pseud and username"

      context "when the comment is a reply to another comment" do
        let(:comment) { create(:comment, commentable: create(:comment, :on_tag), pseud: commenter_pseud) }

        it_behaves_like "a notification email with a link to the comment"
        it_behaves_like "a notification email with a link to reply to the comment"
        it_behaves_like "a notification email with a link to the comment's thread"
        it_behaves_like "a notification email with the commenters pseud and username"
      end
    end
  end

  describe "edited_comment_notification" do
    subject(:email) { CommentMailer.edited_comment_notification(user, comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a notification email with the commenters pseud and username"

    context "when the comment is by an official user using their default pseud" do
      let(:commenter) { create(:official_user, login: "Centrifuge") }
      let(:comment) { create(:comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email that marks the commenter as official"
    end

    context "when the comment is a reply to another comment" do
      let(:comment) { create(:comment, commentable: create(:comment), pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenters pseud and username"
    end

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with the commenters pseud and username"

      context "when the comment is a reply to another comment" do
        let(:comment) { create(:comment, commentable: create(:comment, :on_tag), pseud: commenter_pseud) }

        it_behaves_like "a notification email with a link to the comment"
        it_behaves_like "a notification email with a link to reply to the comment"
        it_behaves_like "a notification email with a link to the comment's thread"
        it_behaves_like "a notification email with the commenters pseud and username"
      end
    end
  end

  describe "comment_reply_notification" do
    subject(:email) { CommentMailer.comment_reply_notification(parent_comment, comment) }

    let(:parent_comment) { create(:comment) }
    let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter_pseud) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a notification email with a link to the comment's thread"
    it_behaves_like "a notification email with the commenters pseud and username"

    context "when the comment is by an official user using their default pseud" do
      let(:commenter) { create(:official_user, login: "Centrifuge") }
      let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email that marks the commenter as official"
    end

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenters pseud and username"
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
    let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter_pseud) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a notification email with a link to the comment's thread"
    it_behaves_like "a notification email with the commenters pseud and username"

    context "when the comment is by an official user using their default pseud" do
      let(:commenter) { create(:official_user, login: "Centrifuge") }
      let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email that marks the commenter as official"
    end

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenters pseud and username"
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
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
    end
  end

  describe "comment_reply_sent_notification" do
    subject(:email) { CommentMailer.comment_reply_sent_notification(comment) }

    let(:parent_comment) { create(:comment, pseud: commenter_pseud) }
    let(:comment) { create(:comment, commentable: parent_comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to the comment's thread"
    it_behaves_like "a notification email with the commenters pseud and username"

    context "when the comment is by an official user using their default pseud" do
      let(:commenter) { create(:official_user, login: "Centrifuge") }
      let(:parent_comment) { create(:comment, pseud: commenter.default_pseud) }
      let(:comment) { create(:comment, commentable: parent_comment) }

      it_behaves_like "a notification email that marks the commenter as official" # for parent comment
    end

    context "when the parent comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenters pseud and username" # for parent comment
    end
  end
end
