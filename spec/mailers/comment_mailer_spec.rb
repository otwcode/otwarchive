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

  shared_examples "a notification email with the commenter's pseud and username" do
    describe "HTML email" do
      it "has the pseud and username of the commenter" do
        expect(email).to have_html_part_content(">Blueprint (Accumulator)</a></strong> <em><strong>(Registered User)</strong></em>")
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
        expect(email).to have_html_part_content(">Centrifuge</a></strong> <em><strong>(Official)</strong></em>")
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

  shared_examples "a notification email that marks the commenter as a guest" do
    describe "HTML email" do
      it "has the name of the guest and the guest role" do
        expect(email).to have_html_part_content(">Defender</b> <em><strong>(Guest)</strong></em>")
      end
    end

    describe "text email" do
      it "has the name of the guest and the guest role" do
        expect(subject).to have_text_part_content("Defender (Guest)")
      end
    end
  end

  shared_examples "a notification email with only the commenter's username" do
    describe "HTML email" do
      it "has only the username of the commenter" do
        expect(email).to have_html_part_content(">Exoskeleton</a></strong> <em><strong>(Registered User)</strong></em>")
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{user_pseud_url(commenter, commenter.default_pseud)}\"]",
          text: "Exoskeleton"
        )
        expect(email).not_to have_html_part_content(">Exoskeleton (Exoskeleton)")
      end
    end

    describe "text email" do
      it "has only the username of the commenter" do
        expect(subject).to have_text_part_content(
          "Exoskeleton (#{user_pseud_url(commenter, commenter.default_pseud)}) (Registered User)"
        )
        expect(subject).not_to have_text_part_content("Exoskeleton (Exoskeleton)")
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
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a notification email with the commenter's pseud and username"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is by an official user using their default pseud" do
      let(:commenter) { create(:official_user, login: "Centrifuge") }
      let(:comment) { create(:comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email that marks the commenter as official"
    end

    context "when the comment is by a guest" do
      let(:comment) { create(:comment, pseud: nil, name: "Defender", email: Faker::Internet.email) }

      it_behaves_like "a notification email that marks the commenter as a guest"
    end

    context "when the comment is by a registered user using their default pseud" do
      let(:commenter) { create(:user, login: "Exoskeleton") }
      let(:comment) { create(:comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email with only the commenter's username"
    end

    context "when the comment is on an admin post" do
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is a reply to another comment" do
      let(:comment) { create(:comment, commentable: create(:comment), pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenter's pseud and username"
      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with the commenter's pseud and username"
      it_behaves_like "a comment subject to image safety mode settings"

      context "when the comment is a reply to another comment" do
        let(:comment) { create(:comment, commentable: create(:comment, :on_tag), pseud: commenter_pseud) }

        it_behaves_like "a notification email with a link to the comment"
        it_behaves_like "a notification email with a link to reply to the comment"
        it_behaves_like "a notification email with a link to the comment's thread"
        it_behaves_like "a notification email with the commenter's pseud and username"
        it_behaves_like "a comment subject to image safety mode settings"
      end
    end
  end

  describe "#edited_comment_notification" do
    subject(:email) { CommentMailer.edited_comment_notification(user, comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a notification email with the commenter's pseud and username"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is by an official user using their default pseud" do
      let(:commenter) { create(:official_user, login: "Centrifuge") }
      let(:comment) { create(:comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email that marks the commenter as official"
    end

    context "when the comment is by a registered user using their default pseud" do
      let(:commenter) { create(:user, login: "Exoskeleton") }
      let(:comment) { create(:comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email with only the commenter's username"
    end

    context "when the comment is on an admin post" do
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is a reply to another comment" do
      let(:comment) { create(:comment, commentable: create(:comment), pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenter's pseud and username"
      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with the commenter's pseud and username"
      it_behaves_like "a comment subject to image safety mode settings"

      context "when the comment is a reply to another comment" do
        let(:comment) { create(:comment, commentable: create(:comment, :on_tag), pseud: commenter_pseud) }

        it_behaves_like "a notification email with a link to the comment"
        it_behaves_like "a notification email with a link to reply to the comment"
        it_behaves_like "a notification email with a link to the comment's thread"
        it_behaves_like "a notification email with the commenter's pseud and username"
        it_behaves_like "a comment subject to image safety mode settings"
      end
    end
  end

  describe "#comment_reply_notification" do
    subject(:email) { CommentMailer.comment_reply_notification(parent_comment, comment) }

    let(:parent_comment) { create(:comment) }
    let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter_pseud) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a notification email with a link to the comment's thread"
    it_behaves_like "a notification email with the commenter's pseud and username"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is by an official user using their default pseud" do
      let(:commenter) { create(:official_user, login: "Centrifuge") }
      let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email that marks the commenter as official"
    end

    context "when the comment is by a guest" do
      let(:comment) { create(:comment, commentable: parent_comment, pseud: nil, name: "Defender", email: Faker::Internet.email) }

      it_behaves_like "a notification email that marks the commenter as a guest"
    end

    context "when the comment is by a registered user using their default pseud" do
      let(:commenter) { create(:user, login: "Exoskeleton") }
      let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email with only the commenter's username"
    end

    context "when the comment is on an admin post" do
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenter's pseud and username"
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

    context "when the comment is from the author of the anonymous work" do
      let(:work) { create(:work, authors: [commenter_pseud], collections: [create(:anonymous_collection)]) }
      let(:parent_comment) { create(:comment, commentable: work) }
      let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter_pseud) }

      describe "HTML email" do
        it "does not reveal the pseud of the replier" do
          expect(subject).to have_html_part_content(">Anonymous Creator</b>")
          expect(email).not_to have_html_part_content(">Blueprint (Accumulator)")
        end
      end

      describe "text email" do
        it "does not reveal the pseud of the replier" do
          expect(subject).to have_text_part_content("Anonymous Creator")
          expect(subject).not_to have_text_part_content("Blueprint (Accumulator)")
        end
      end
    end
  end

  describe "#edited_comment_reply_notification" do
    subject(:email) { CommentMailer.edited_comment_reply_notification(parent_comment, comment) }

    let(:parent_comment) { create(:comment) }
    let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter_pseud) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to reply to the comment"
    it_behaves_like "a notification email with a link to the comment's thread"
    it_behaves_like "a notification email with the commenter's pseud and username"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is by an official user using their default pseud" do
      let(:commenter) { create(:official_user, login: "Centrifuge") }
      let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email that marks the commenter as official"
    end

    context "when the comment is by a registered user using their default pseud" do
      let(:commenter) { create(:user, login: "Exoskeleton") }
      let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email with only the commenter's username"
    end

    context "when the comment is on an admin post" do
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenter's pseud and username"
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

  describe "#comment_sent_notification" do
    subject(:email) { CommentMailer.comment_sent_notification(comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
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

  describe "#comment_reply_sent_notification" do
    subject(:email) { CommentMailer.comment_reply_sent_notification(comment) }

    let(:parent_comment) { create(:comment, pseud: commenter_pseud) }
    let(:comment) { create(:comment, commentable: parent_comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to the comment's thread"
    it_behaves_like "a notification email with the commenter's pseud and username"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is on an admin post" do
      let(:parent_comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is by an official user using their default pseud" do
      let(:commenter) { create(:official_user, login: "Centrifuge") }
      let(:parent_comment) { create(:comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email that marks the commenter as official" # for parent comment
    end

    context "when the comment is by a registered user using their default pseud" do
      let(:commenter) { create(:user, login: "Exoskeleton") }
      let(:parent_comment) { create(:comment, pseud: commenter.default_pseud) }

      it_behaves_like "a notification email with only the commenter's username" # for parent comment
    end

    context "when the parent comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenter's pseud and username" # for parent comment
      it_behaves_like "a comment subject to image safety mode settings"
    end
  end
end
