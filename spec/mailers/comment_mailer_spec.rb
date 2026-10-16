require "spec_helper"

describe CommentMailer do
  include ActiveJob::TestHelper
  def queue_adapter_for_test
    ActiveJob::QueueAdapters::TestAdapter.new
  end

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
      it "strips the image from the email when image safety mode is completely disabled" do
        allow(ArchiveConfig).to receive(:PARENTS_WITH_IMAGE_SAFETY_MODE).and_return([])
        expect(email).not_to have_html_part_content(image_tag)
        expect(email).not_to have_text_part_content(image_tag)
        expect(email).to have_html_part_content(image_url)
        expect(email).to have_text_part_content(image_url)
      end

      it "strips the image from the HTML email when image safety mode is enabled for other parent types" do
        allow(ArchiveConfig).to receive(:PARENTS_WITH_IMAGE_SAFETY_MODE).and_return(all_parent_types - comment_parent_type)
        expect(email).not_to have_html_part_content(image_tag)
        expect(email).not_to have_text_part_content(image_tag)
        expect(email).to have_html_part_content(image_url)
        expect(email).to have_text_part_content(image_url)
      end
    end
  end

  shared_examples "a notification email for admins" do
    it "is not delivered to the admin who is the commentable owner" do
      expect(email).not_to deliver_to(comment.ultimate_parent.commentable_owners.first.email)
    end

    it "is delivered to the admin address" do
      expect(email).to deliver_to(ArchiveConfig.ADMIN_ADDRESS)
    end
  end

  shared_examples "a notification email to someone who can review comments" do
    describe "HTML email" do
      it "has a note about needing to approve comments" do
        note = if comment.ultimate_parent.is_a?(AdminPost)
                 "Comments on this news post are moderated and will not appear until approved."
               else
                 "Comments on this work are moderated and will not appear until you approve them."
               end
        expect(subject).to have_html_part_content(note)
      end

      it "has a link to review comments" do
        url = if comment.ultimate_parent.is_a?(AdminPost)
                unreviewed_admin_post_comments_url(comment.ultimate_parent)
              else
                unreviewed_work_comments_url(comment.ultimate_parent)
              end
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{url}\"]",
          text: "Review comments on #{comment.ultimate_parent.commentable_name}"
        )
      end
    end

    describe "text email" do
      it "has a note about needing to approve comments" do
        note = if comment.ultimate_parent.is_a?(AdminPost)
                 "Comments on this news post are moderated and will not appear until approved."
               else
                 "Comments on this work are moderated and will not appear until you approve them."
               end
        expect(subject).to have_text_part_content(note)
      end

      it "has a link to review comments" do
        url = if comment.ultimate_parent.is_a?(AdminPost)
                unreviewed_admin_post_comments_url(comment.ultimate_parent)
              else
                unreviewed_work_comments_url(comment.ultimate_parent)
              end
        expect(subject).to have_text_part_content("Review comments on \"#{comment.ultimate_parent.commentable_name}\": #{url}")
      end
    end
  end

  shared_examples "a notification concerning a chapter" do
    it "has the chapter in the subject line" do
      expect(subject.subject).to include("Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}")
    end

    describe "HTML email" do
      it "has a link to view all comments on the chapter" do
        url = work_chapter_url(comment.parent.work,
                               comment.parent,
                               show_comments: true,
                               anchor: :comments)

        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{url}\"]",
          text: "Read all comments on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        )
      end
    end

    describe "text email" do
      it "has a link to view all comments on the chapter" do
        url = work_chapter_url(comment.parent.work,
                               comment.parent,
                               show_comments: true,
                               anchor: :comments)
        expect(subject).to have_text_part_content("Read all comments on Chapter #{comment.parent.position} of \"#{comment.ultimate_parent.commentable_name}\": #{url}")
      end
    end
  end

  shared_examples "a notification with a titled chapter reference" do
    describe "HTML email" do
      it "has a link to the chapter including its title" do
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{work_chapter_url(comment.parent.work, comment.parent)}\"]",
          text: "Chapter #{comment.parent.position}: #{comment.parent.title}"
        )
      end
    end

    describe "text email" do
      it "has a reference to the chapter including its title" do
        expect(subject).to have_text_part_content("comment on Chapter #{comment.parent.position}: #{comment.parent.title} of #{comment.ultimate_parent.commentable_name} (#{work_chapter_url(comment.parent.work, comment.parent)})")
      end
    end
  end

  shared_examples "a notification with an untitled chapter reference" do
    describe "HTML email" do
      it "has a link to the chapter without a title" do
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{work_chapter_url(comment.parent.work, comment.parent)}\"]",
          text: "Chapter #{comment.parent.position}"
        )
      end
    end

    describe "text email" do
      it "has a reference to the chapter without a title" do
        expect(subject).to have_text_part_content("comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name} (#{work_chapter_url(comment.parent.work, comment.parent)})")
      end
    end
  end

  shared_examples "a notification without a chapter reference" do
    it "has no chapter information in the subject line" do
      expect(subject.subject).to_not include("on Chapter")
    end

    describe "HTML email" do
      it "has no reference to the chapter" do
        expect(subject).to_not have_html_part_content("comment on Chapter")
      end

      it "has a link to the work" do
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{work_url(comment.ultimate_parent)}\"]",
          text: comment.commentable_name
        )
      end

      it "has a link to view all comments on the work" do
        url = work_url(comment.ultimate_parent, view_full_work: true, show_comments: true, anchor: :comments)
        expect(subject.html_part).to have_xpath(
          "//a[@href=\"#{url}\"]",
          text: "Read all comments on #{comment.ultimate_parent.commentable_name}"
        )
      end
    end

    describe "text email" do
      it "has no reference to the chapter" do
        expect(subject).to_not have_text_part_content("comment on Chapter")
      end

      it "has a link to the work" do
        expect(subject).to have_text_part_content("comment on #{comment.ultimate_parent.commentable_name} (#{work_url(comment.ultimate_parent)})")
      end

      it "has a link to view all comments on the work" do
        url = work_url(comment.ultimate_parent, view_full_work: true, show_comments: true, anchor: :comments)
        expect(subject).to have_text_part_content("Read all comments on \"#{comment.ultimate_parent.commentable_name}\": #{url}")
      end
    end
  end

  shared_examples "a notification email to someone who can't review comments" do
    describe "HTML email" do
      it "has a note about the comment not appearing until it is approved" do
        note = if comment.ultimate_parent.is_a?(AdminPost)
                 "Comments on this news post are moderated and will not appear until approved."
               else
                 "Comments on this work are moderated and will not appear until approved by the work creator."
               end
        expect(subject).to have_html_part_content(note)
      end

      it "does not have a link to review comments" do
        url = if comment.ultimate_parent.is_a?(AdminPost)
                unreviewed_admin_post_comments_url(comment.ultimate_parent)
              else
                unreviewed_work_comments_url(comment.ultimate_parent)
              end
        expect(subject.html_part).not_to have_xpath(
          "//a[@href=\"#{url}\"]",
          text: "Review comments on #{comment.ultimate_parent.commentable_name}"
        )
      end
    end

    describe "text email" do
      it "has a note about the comment not appearing until it is approved" do
        note = if comment.ultimate_parent.is_a?(AdminPost)
                 "Comments on this news post are moderated and will not appear until approved."
               else
                 "Comments on this work are moderated and will not appear until approved by the work creator."
               end
        expect(subject).to have_text_part_content(note)
      end

      it "does not have a link to review comments" do
        url = if comment.ultimate_parent.is_a?(AdminPost)
                unreviewed_admin_post_comments_url(comment.ultimate_parent)
              else
                unreviewed_work_comments_url(comment.ultimate_parent)
              end
        expect(subject).not_to have_text_part_content("Review comments on \"#{comment.ultimate_parent.commentable_name}\": #{url}")
      end
    end
  end

  describe "#comment_notification" do
    subject(:email) { CommentMailer.comment_notification(user, comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "a translated email"
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
      let(:user) { comment.ultimate_parent.commentable_owners.first }
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a notification email for admins"
      it_behaves_like "a comment subject to image safety mode settings"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Comment on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      context "when the comment is unreviewed" do
        before { comment.update!(unreviewed: true) }

        it_behaves_like "a notification email to someone who can review comments"
      end
    end

    context "when the comment is a reply to another comment" do
      let(:comment) { create(:comment, commentable: create(:comment), pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenter's pseud and username"
      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is unreviewed" do
      before { comment.update!(unreviewed: true) }

      it_behaves_like "a notification email to someone who can review comments"
    end

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with the commenter's pseud and username"
      it_behaves_like "a comment subject to image safety mode settings"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Comment on the tag #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      context "when the comment is a reply to another comment" do
        let(:comment) { create(:comment, commentable: create(:comment, :on_tag), pseud: commenter_pseud) }

        it_behaves_like "a notification email with a link to the comment"
        it_behaves_like "a notification email with a link to reply to the comment"
        it_behaves_like "a notification email with a link to the comment's thread"
        it_behaves_like "a notification email with the commenter's pseud and username"
        it_behaves_like "a comment subject to image safety mode settings"
      end
    end

    context "when the comment is on a single-chapter work" do
      let(:work) { create(:work, expected_number_of_chapters: 1) }
      let(:comment) { create(:comment, commentable: work.first_chapter) }

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Comment on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      it_behaves_like "a notification without a chapter reference"
    end

    context "when the comment is on an untitled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:comment) { create(:comment, commentable: work.first_chapter) }

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with an untitled chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end
    
    context "when the comment is on a titled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:chapter) { create(:chapter, work: work, title: "Some Chapter") }
      let(:comment) { create(:comment, commentable: chapter) }

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with a titled chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end
  end

  describe "#edited_comment_notification" do
    subject(:email) { CommentMailer.edited_comment_notification(user, comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "a translated email"
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
      let(:user) { comment.ultimate_parent.commentable_owners.first }
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a notification email for admins"
      it_behaves_like "a comment subject to image safety mode settings"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Edited comment on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      context "when the comment is unreviewed" do
        before { comment.update!(unreviewed: true) }

        it_behaves_like "a notification email to someone who can review comments"
      end
    end

    context "when the comment is a reply to another comment" do
      let(:comment) { create(:comment, commentable: create(:comment), pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenter's pseud and username"
      it_behaves_like "a comment subject to image safety mode settings"
    end

    context "when the comment is unreviewed" do
      before { comment.update!(unreviewed: true) }

      it_behaves_like "a notification email to someone who can review comments"
    end

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with the commenter's pseud and username"
      it_behaves_like "a comment subject to image safety mode settings"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Edited comment on the tag #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      context "when the comment is a reply to another comment" do
        let(:comment) { create(:comment, commentable: create(:comment, :on_tag), pseud: commenter_pseud) }

        it_behaves_like "a notification email with a link to the comment"
        it_behaves_like "a notification email with a link to reply to the comment"
        it_behaves_like "a notification email with a link to the comment's thread"
        it_behaves_like "a notification email with the commenter's pseud and username"
        it_behaves_like "a comment subject to image safety mode settings"
      end
    end

    context "when the comment is on a single-chapter work" do
      let(:work) { create(:work, expected_number_of_chapters: 1) }
      let(:comment) { create(:comment, commentable: work.first_chapter) }

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Edited comment on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      it_behaves_like "a notification without a chapter reference"
    end

    context "when the comment is on an untitled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:comment) { create(:comment, commentable: work.first_chapter) }

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Edited comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with an untitled chapter reference"
    end

    context "when the comment is on a titled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:chapter) { create(:chapter, work: work, title: "Some Chapter") }
      let(:comment) { create(:comment, commentable: chapter) }

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Edited comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with a titled chapter reference"
    end
  end

  describe "#comment_reply_notification" do
    subject(:email) { CommentMailer.comment_reply_notification(parent_comment, comment) }

    let(:parent_comment) { create(:comment) }
    let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter_pseud) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "a translated email"
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

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reply to your comment on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      context "when the comment is unreviewed" do
        before { comment.update!(unreviewed: true) }

        it_behaves_like "a notification email to someone who can't review comments"
      end
    end

    context "when the comment is unreviewed" do
      before { comment.update!(unreviewed: true) }

      it_behaves_like "a notification email to someone who can't review comments"
    end

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenter's pseud and username"
      it_behaves_like "a comment subject to image safety mode settings"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reply to your comment on the tag #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
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

    context "when the comment is on a single-chapter work" do
      let(:work) { create(:work, expected_number_of_chapters: 1) }
      let(:parent_comment) { create(:comment, commentable: work.first_chapter) }

      it_behaves_like "a notification without a chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reply to your comment on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end

    context "when the comment is on an untitled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:parent_comment) { create(:comment, commentable: work.first_chapter) }

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with an untitled chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reply to your comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end

    context "when the comment is on a titled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:chapter) { create(:chapter, work: work, title: "Some Chapter") }
      let(:parent_comment) { create(:comment, commentable: chapter) }

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with a titled chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reply to your comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end
  end

  describe "#edited_comment_reply_notification" do
    subject(:email) { CommentMailer.edited_comment_reply_notification(parent_comment, comment) }

    let(:parent_comment) { create(:comment) }
    let(:comment) { create(:comment, commentable: parent_comment, pseud: commenter_pseud) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "a translated email"
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

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Edited reply to your comment on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      context "when the comment is unreviewed" do
        before { comment.update!(unreviewed: true) }

        it_behaves_like "a notification email to someone who can't review comments"
      end
    end

    context "when the comment is unreviewed" do
      before { comment.update!(unreviewed: true) }

      it_behaves_like "a notification email to someone who can't review comments"
    end

    context "when the comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to reply to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenter's pseud and username"
      it_behaves_like "a comment subject to image safety mode settings"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Edited reply to your comment on the tag #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
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

    context "when the comment is on a single-chapter work" do
      let(:work) { create(:work, expected_number_of_chapters: 1) }
      let(:parent_comment) { create(:comment, commentable: work.first_chapter) }

      it_behaves_like "a notification without a chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Edited reply to your comment on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end

    context "when the comment is on an untitled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:parent_comment) { create(:comment, commentable: work.first_chapter) }

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with an untitled chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Edited reply to your comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end

    context "when the comment is on a titled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:chapter) { create(:chapter, work: work, title: "Some Chapter") }
      let(:parent_comment) { create(:comment, commentable: chapter) }

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with a titled chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Edited reply to your comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end
  end

  describe "#comment_sent_notification" do
    subject(:email) { CommentMailer.comment_sent_notification(comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "a translated email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is on an admin post" do
      let(:comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Comment you left on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      context "when the comment is unreviewed" do
        before { comment.update!(unreviewed: true) }

        it_behaves_like "a notification email to someone who can't review comments"
      end
    end

    context "when the comment is unreviewed" do
      before { comment.update!(unreviewed: true) }

      it_behaves_like "a notification email to someone who can't review comments"
    end

    context "when the comment is on a tag" do
      let(:comment) { create(:comment, :on_tag) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a comment subject to image safety mode settings"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Comment you left on the tag #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end

    context "when the comment is on a single-chapter work" do
      let(:work) { create(:work, expected_number_of_chapters: 1) }
      let(:comment) { create(:comment, commentable: work.first_chapter) }

      it_behaves_like "a notification without a chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Comment you left on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end

    context "when the comment is on an untitled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:comment) { create(:comment, commentable: work.first_chapter) }

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with an untitled chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Comment you left on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end

    context "when the comment is on a titled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:chapter) { create(:chapter, work: work, title: "Some Chapter") }
      let(:comment) { create(:comment, commentable: chapter) }

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with a titled chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Comment you left on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end
  end

  describe "#comment_reply_sent_notification" do
    subject(:email) { CommentMailer.comment_reply_sent_notification(comment) }

    let(:parent_comment) { create(:comment, pseud: commenter_pseud) }
    let(:comment) { create(:comment, commentable: parent_comment) }

    it_behaves_like "an email with a valid sender"
    it_behaves_like "a multipart email"
    it_behaves_like "a translated email"
    it_behaves_like "it retries when the comment doesn't exist"
    it_behaves_like "a notification email with a link to the comment"
    it_behaves_like "a notification email with a link to the comment's thread"
    it_behaves_like "a notification email with the commenter's pseud and username"
    it_behaves_like "a comment subject to image safety mode settings"

    context "when the comment is on an admin post" do
      let(:parent_comment) { create(:comment, :on_admin_post) }

      it_behaves_like "a comment subject to image safety mode settings"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reply you left to a comment on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end

      context "when the comment is unreviewed" do
        before { comment.update!(unreviewed: true) }

        it_behaves_like "a notification email to someone who can't review comments"
      end
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

    context "when the comment is unreviewed" do
      before { comment.update!(unreviewed: true) }

      it_behaves_like "a notification email to someone who can't review comments"
    end

    context "when the parent comment is on a tag" do
      let(:parent_comment) { create(:comment, :on_tag, pseud: commenter_pseud) }

      it_behaves_like "a notification email with a link to the comment"
      it_behaves_like "a notification email with a link to the comment's thread"
      it_behaves_like "a notification email with the commenter's pseud and username" # for parent comment
      it_behaves_like "a comment subject to image safety mode settings"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reply you left to a comment on the tag #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end

    context "when the comment is on a single-chapter work" do
      let(:work) { create(:work, expected_number_of_chapters: 1) }
      let(:parent_comment) { create(:comment, commentable: work.first_chapter) }

      it_behaves_like "a notification without a chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reply you left to a comment on #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end

    context "when the comment is on an untitled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:parent_comment) { create(:comment, commentable: work.first_chapter) }

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with an untitled chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reply you left to a comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end

    context "when the comment is on a titled chapter" do
      let(:work) { create(:work, expected_number_of_chapters: 2) }
      let(:chapter) { create(:chapter, work: work, title: "Some Chapter") }
      let(:parent_comment) { create(:comment, commentable: chapter) }

      it_behaves_like "a notification concerning a chapter"
      it_behaves_like "a notification with a titled chapter reference"

      it "has the correct subject line" do
        subject = "[#{ArchiveConfig.APP_SHORT_NAME}] Reply you left to a comment on Chapter #{comment.parent.position} of #{comment.ultimate_parent.commentable_name}"
        expect(email).to have_subject(subject)
      end
    end
  end
end
