# frozen_string_literal: true

require "spec_helper"

describe Comment do
  describe "validations" do
    context "with a forbidden guest name" do
      subject { build(:comment, email: Faker::Internet.email) }
      let(:forbidden_name) { Faker::Lorem.characters(number: 8) }

      before do
        allow(ArchiveConfig).to receive(:FORBIDDEN_USERNAMES).and_return([forbidden_name])
      end

      it { is_expected.not_to allow_values(forbidden_name, forbidden_name.swapcase).for(:name) }

      it "does not prevent saving when the name is unchanged" do
        subject.name = forbidden_name
        subject.save!(validate: false)
        expect(subject.save).to be_truthy
      end

      it "does not prevent deletion" do
        subject.name = forbidden_name
        subject.save!(validate: false)
        subject.destroy
        expect { subject.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    shared_examples "disallows editing the comment if it's changed significantly" do
      it "prevents editing the comment if it's changed significantly" do
        subject.edited_at = Time.current
        subject.comment_content = "Spam content" * 12
        expect(subject.save).to be_falsey
        expect(subject.errors[:base]).to include("This comment looks like spam to our system, sorry! Please try again.")
      end

      it "allows editing the comment if it's not changed significantly" do
        subject.edited_at = Time.current
        subject.comment_content += "a"
        expect(subject.save).to be_truthy
      end

      it "allows modifying the comment besides content" do
        subject.hidden_by_admin = true
        expect(subject.save).to be_truthy
      end
    end

    shared_examples "always allows changing the comment" do
      it "allows editing the comment if it's changed significantly" do
        subject.edited_at = Time.current
        subject.comment_content = "Spam content" * 12
        expect(subject.save).to be_truthy
      end

      it "allows editing the comment if it's not changed significantly" do
        subject.edited_at = Time.current
        subject.comment_content += "a"
        expect(subject.save).to be_truthy
      end
    end

    context "when any comment is considered spam" do
      subject { build(:comment, pseud: user.default_pseud) }
      let(:admin_setting) { AdminSetting.first || AdminSetting.create }

      before do
        subject.save!
        allow_any_instance_of(Comment).to receive(:spam?).and_return(true)
      end

      context "when account_age_threshold_for_comment_spam_check is set" do
        before do
          admin_setting.update_attribute(:account_age_threshold_for_comment_spam_check, 10)
        end

        context "for a new user" do
          let(:user) { create(:user, created_at: Time.current) }

          it_behaves_like "disallows editing the comment if it's changed significantly"

          context "on the commenters own work" do
            subject { build(:comment, pseud: user.default_pseud, commentable: work) }
            let(:work) { create(:work, authors: [user.default_pseud]) }

            it_behaves_like "always allows changing the comment"

            context "comment is a reply" do
              subject { build(:comment, pseud: user.default_pseud, commentable: comment) }
              let(:comment) { build(:comment, commentable: work) }

              it_behaves_like "always allows changing the comment"
            end
          end

          context "on a tag" do
            subject { build(:comment, :on_tag, pseud: user.default_pseud) }

            it_behaves_like "always allows changing the comment"
          end

          context "on an admin post" do
            subject { build(:comment, :on_admin_post, pseud: user.default_pseud) }

            it_behaves_like "disallows editing the comment if it's changed significantly"
          end
        end

        context "for an old user" do
          let(:user) { create(:user, created_at: 12.days.ago) }

          it_behaves_like "always allows changing the comment"

          context "on the commenters own work" do
            subject { build(:comment, pseud: user.default_pseud, commentable: work) }
            let(:work) { create(:work, authors: [user.default_pseud]) }

            it_behaves_like "always allows changing the comment"
          end

          context "on a tag" do
            subject { build(:comment, :on_tag, pseud: user.default_pseud) }

            it_behaves_like "always allows changing the comment"
          end

          context "on an admin post" do
            subject { build(:comment, :on_admin_post, pseud: user.default_pseud) }

            it_behaves_like "always allows changing the comment"
          end

          context "when they change their email address" do
            before do
              user.update!(confirmed_at: Time.current)
            end

            subject { build(:comment, :on_admin_post, pseud: user.default_pseud) }

            it_behaves_like "always allows changing the comment"
          end
        end
      end

      context "when account_age_threshold_for_comment_spam_check is unset" do
        before do
          admin_setting.update_attribute(:account_age_threshold_for_comment_spam_check, 0)
        end

        context "for a new user" do
          let(:user) { create(:user, created_at: Time.current) }

          it_behaves_like "always allows changing the comment"

          context "on the commenters own work" do
            subject { build(:comment, pseud: user.default_pseud, commentable: work) }
            let(:work) { create(:work, authors: [user.default_pseud]) }

            it_behaves_like "always allows changing the comment"
          end

          context "on an admin post" do
            subject { build(:comment, :on_admin_post, pseud: user.default_pseud) }

            it_behaves_like "always allows changing the comment"
          end
        end
      end
    end

    context "when submitting comment to Akismet" do
      subject { create(:comment) }

      it "has user_role \"user\"" do
        expect(subject.akismet_attributes[:user_role]).to eq("user")
      end

      it "has comment_author as the user's username" do
        expect(subject.akismet_attributes[:comment_author]).to eq(subject.pseud.user.login)
      end

      it "has comment_author_email as the user's email" do
        expect(subject.akismet_attributes[:comment_author_email]).to eq(subject.pseud.user.email)
      end

      context "when the comment is from a guest" do
        subject { create(:comment, :by_guest) }

        it "has user_role \"guest\"" do
          expect(subject.akismet_attributes[:user_role]).to eq("guest")
        end

        it "has comment_author as the commenter's name" do
          expect(subject.akismet_attributes[:comment_author]).to eq(subject.name)
        end
  
        it "has comment_author_email as the commenter's email" do
          expect(subject.akismet_attributes[:comment_author_email]).to eq(subject.email)
        end
      end

      context "when the commentable is a chapter" do
        it "has comment_type \"fanwork-comment\"" do
          expect(subject.akismet_attributes[:comment_type]).to eq("fanwork-comment")
        end
      end

      context "when the commentable is an admin post" do
        subject { create(:comment, :on_admin_post) }

        it "has comment_type \"comment\"" do
          expect(subject.akismet_attributes[:comment_type]).to eq("comment")
        end
      end

      context "when the commentable is a comment" do
        context "when the comment is on a chapter" do
          subject { create(:comment, commentable: create(:comment)) }

          it "has comment_type \"fanwork-comment\"" do
            expect(subject.akismet_attributes[:comment_type]).to eq("fanwork-comment")
          end
        end

        context "when the comment is on an admin post" do
          subject { create(:comment, commentable: create(:comment, :on_admin_post)) }

          it "has comment_type \"comment\"" do
            expect(subject.akismet_attributes[:comment_type]).to eq("comment")
          end
        end
      end
    end
  end

  context "with an existing comment from the same user" do 
    let(:first_comment) { create(:comment) }

    let(:second_comment) do
      attributes = %w[pseud_id commentable_id commentable_type comment_content name email]
      Comment.new(first_comment.attributes.slice(*attributes))
    end

    it "should be invalid if exactly duplicated" do 
      expect(second_comment.valid?).to be_falsy
      expect(second_comment.errors.attribute_names).to include(:comment_content)
      expect(second_comment.errors.full_messages.first).to include("You've already")
    end

    it "should not be invalid if in the process of being deleted" do
      second_comment.is_deleted = true
      expect(second_comment.valid?).to be_truthy
    end
  end

  context "with blocking" do
    let(:blocked) { create(:user) }

    let(:comment) do
      Comment.new(commentable: commentable,
                  pseud: blocked.default_pseud,
                  comment_content: "Hmm.")
    end

    before { Block.create(blocker: blocker, blocked: blocked) }

    shared_examples "creating and editing comments is allowed" do
      describe "save" do
        it "allows new comments" do
          expect(comment.save).to be_truthy
          expect(comment.errors.full_messages).to be_blank
        end
      end

      describe "update" do
        before { comment.save(validate: false) }

        it "changes the comment" do
          comment.update!(comment_content: "Why did you block me?")
          expect(comment.errors.full_messages).to be_blank
          expect(comment.reload.comment_content).to eq("Why did you block me?")
        end
      end
    end

    shared_examples "creating and editing comments is not allowed" do |message:|
      describe "save" do
        it "doesn't allow new comments" do
          expect(comment.save).to be_falsey
          expect(comment.errors.full_messages).to include(message)
        end
      end

      describe "update" do
        before { comment.save(validate: false) }

        it "doesn't change the comment" do
          expect { comment.update!(comment_content: "Why did you block me?") }
            .to raise_error(ActiveRecord::RecordInvalid)
          expect(comment.errors.full_messages).to include(message)
          expect(comment.reload.comment_content).to eq("Hmm.")
        end
      end
    end

    shared_examples "deleting comments is allowed" do
      describe "destroy_or_mark_deleted" do
        before { comment.save(validate: false) }

        it "allows deleting comments" do
          expect(comment.destroy_or_mark_deleted).to be_truthy
          expect { comment.reload }.to raise_exception ActiveRecord::RecordNotFound
        end

        it "allows deleting comments with replies" do
          create(:comment, commentable: comment)
          expect(comment.destroy_or_mark_deleted).to be_truthy
          expect { comment.reload }.not_to raise_exception
          expect(comment.is_deleted).to be_truthy
          expect(comment.comment_content).to eq("deleted comment")
        end
      end
    end

    context "when the commenter is blocked by the work's owner" do
      let(:work) { create(:work) }
      let(:blocker) { work.users.first }

      context "when commenting directly on the work" do
        let(:commentable) { work.first_chapter }

        it_behaves_like "creating and editing comments is not allowed",
                        message: "Sorry, you have been blocked by one or more of this work's creators."
        it_behaves_like "deleting comments is allowed"
      end

      context "when replying to someone else's comment on the work" do
        let(:commentable) { create(:comment, commentable: work.first_chapter) }

        it_behaves_like "creating and editing comments is not allowed",
                        message: "Sorry, you have been blocked by one or more of this work's creators."
        it_behaves_like "deleting comments is allowed"
      end
    end

    context "when the commenter shares the work with their blocker" do
      let(:blocker) { create(:user) }
      let(:work) { create(:work, authors: [blocker.default_pseud, blocked.default_pseud]) }

      context "when commenting directly on the work" do
        let(:commentable) { work.first_chapter }

        it_behaves_like "creating and editing comments is allowed"
        it_behaves_like "deleting comments is allowed"
      end

      context "when replying to someone else's comment on the work" do
        let(:commentable) { create(:comment, commentable: work.first_chapter) }

        it_behaves_like "creating and editing comments is allowed"
        it_behaves_like "deleting comments is allowed"
      end

      context "when replying to their blocker on their shared work" do
        let(:commentable) { create(:comment, pseud: blocker.default_pseud, commentable: work.first_chapter) }

        it_behaves_like "creating and editing comments is not allowed",
                        message: "Sorry, you have been blocked by that user."
        it_behaves_like "deleting comments is allowed"
      end
    end

    context "when the commenter is blocked by the person they're replying to" do
      let(:blocker) { commentable.user }

      context "on a work" do
        let(:commentable) { create(:comment) }

        it_behaves_like "creating and editing comments is not allowed",
                        message: "Sorry, you have been blocked by that user."
        it_behaves_like "deleting comments is allowed"
      end

      context "on an admin post" do
        let(:commentable) { create(:comment, :on_admin_post) }

        it_behaves_like "creating and editing comments is not allowed",
                        message: "Sorry, you have been blocked by that user."
        it_behaves_like "deleting comments is allowed"
      end

      context "on a tag" do
        let(:commentable) { create(:comment, :on_tag) }

        it_behaves_like "creating and editing comments is allowed"
        it_behaves_like "deleting comments is allowed"
      end
    end
  end

  context "when user has disabled guest replies" do
    let(:no_reply_guy) do
      user = create(:user)
      user.preference.update!(guest_replies_off: true)
      user
    end

    let(:guest_reply) do
      Comment.new(commentable: comment,
                  pseud: nil,
                  name: "unwelcome guest",
                  email: Faker::Internet.email,
                  comment_content: "I'm a vampire.")
    end

    let(:user_reply) do
      Comment.new(commentable: comment,
                  pseud: create(:user).default_pseud,
                  comment_content: "Hmm.")
    end

    shared_examples "creating guest reply is allowed" do
      describe "save" do
        it "allows guest replies" do
          expect(guest_reply.save).to be_truthy
          expect(guest_reply.errors.full_messages).to be_blank
        end

        it "allows user replies" do
          expect(user_reply.save).to be_truthy
          expect(user_reply.errors.full_messages).to be_blank
        end
      end
    end

    shared_examples "creating guest reply is not allowed" do
      describe "save" do
        it "doesn't allow guest replies" do
          expect(guest_reply.save).to be_falsey
          expect(guest_reply.errors.full_messages).to include("Sorry, this user doesn't allow non-Archive users to reply to their comments.")
        end

        it "allows user replies" do
          expect(user_reply.save).to be_truthy
          expect(user_reply.errors.full_messages).to be_blank
        end
      end
    end

    context "comment on a work" do
      let(:comment) { create(:comment, pseud: no_reply_guy.default_pseud) }

      include_examples "creating guest reply is not allowed"
    end

    context "comment on an admin post" do
      let(:comment) { create(:comment, :on_admin_post, pseud: no_reply_guy.default_pseud) }

      include_examples "creating guest reply is not allowed"
    end

    context "comment on a tag" do
      let(:comment) { create(:comment, :on_tag, pseud: no_reply_guy.default_pseud) }

      include_examples "creating guest reply is not allowed"
    end

    context "comment on the user's work" do
      let(:work) { create(:work, authors: [no_reply_guy.default_pseud]) }
      let(:comment) { create(:comment, pseud: no_reply_guy.default_pseud, commentable: work.first_chapter) }

      include_examples "creating guest reply is allowed"
    end

    context "comment on the user's co-creation" do
      let(:work) { create(:work, authors: [create(:user).default_pseud, no_reply_guy.default_pseud]) }
      let(:comment) { create(:comment, pseud: no_reply_guy.default_pseud, commentable: work.first_chapter) }

      include_examples "creating guest reply is allowed"
    end

    context "guest comment" do
      let(:comment) { create(:comment, :by_guest) }

      include_examples "creating guest reply is allowed"
    end
  end

  describe "#create" do
    context "as a tag wrangler" do
      let(:tag_wrangler) { create(:tag_wrangler) }

      before do
        tag_wrangler.last_wrangling_activity.updated_at = 60.days.ago
        tag_wrangler.last_wrangling_activity.save!(touch: false)
      end

      shared_examples "updates last wrangling activity" do
        it "tracks last wrangling activity" do
          expect(tag_wrangler.reload.last_wrangling_activity.updated_at).to be_within(1.minute).of Time.current
        end
      end

      context "direct parent is a tag" do
        before { create(:comment, :on_tag, pseud: tag_wrangler.default_pseud) }

        include_examples "updates last wrangling activity"
      end

      context "ultimate parent is indirectly a tag" do
        let(:parent_comment) { create(:comment, :on_tag) }

        before { create(:comment, commentable: parent_comment, pseud: tag_wrangler.default_pseud) }

        include_examples "updates last wrangling activity"
      end

      shared_examples "does not update last wrangling activity" do
        it "does not track last wrangling activity" do
          expect(tag_wrangler.reload.last_wrangling_activity.updated_at).to be_within(1.minute).of 60.days.ago
        end
      end

      context "parent is a work" do
        before { create(:comment, pseud: tag_wrangler.default_pseud) }

        include_examples "does not update last wrangling activity"
      end

      context "parent is an admin comment" do
        before { create(:comment, :on_admin_post, pseud: tag_wrangler.default_pseud) }

        include_examples "does not update last wrangling activity"
      end
    end

    context "as a non-tag wrangler" do
      let(:user) { create(:archivist) }

      context "parent is a tag" do
        before { create(:comment, :on_tag, pseud: user.default_pseud) }

        it "does not update last wrangling activity" do
          expect(user.last_wrangling_activity).to be_nil
        end
      end
    end

    context "as non-user" do
      context "parent is a tag" do
        before { create(:comment, :by_guest, :on_tag) }

        it "does not update last wrangling activity" do
          expect(LastWranglingActivity.all).to be_empty
        end
      end
    end
  end

  describe "#update" do
    context "as a tag wrangler" do
      let(:tag_wrangler) { create(:tag_wrangler) }

      context "direct parent is a tag" do
        let!(:comment) { create(:comment, :on_tag, pseud: tag_wrangler.default_pseud) }

        it "does not update last wrangling activity" do
          expect do
            comment.update!(comment_content: Faker::Lorem.sentence(word_count: 25))
          end.not_to change { tag_wrangler.reload.last_wrangling_activity.updated_at }
        end
      end
    end
  end

  describe "#destroy" do
    context "as a tag wrangler" do
      let(:tag_wrangler) { create(:tag_wrangler) }

      context "direct parent is a tag" do
        let!(:comment) { create(:comment, :on_tag, pseud: tag_wrangler.default_pseud) }

        it "does not update last wrangling activity" do
          expect do
            comment.destroy
          end.not_to change { tag_wrangler.reload.last_wrangling_activity.updated_at }
        end
      end
    end
  end

  describe "#use_image_safety_mode?" do
    let(:admin_post_comment) { create(:comment, :on_admin_post) }
    let(:chapter_comment) { create(:comment) }
    let(:tag_comment) { create(:comment, :on_tag) }
    let(:admin_post_reply) { create(:comment, commentable: admin_post_comment) }
    let(:chapter_reply) { create(:comment, commentable: chapter_comment) }
    let(:tag_reply) { create(:comment, commentable: tag_comment) }

    context "when ArchiveConfig.PARENTS_WITH_IMAGE_SAFETY_MODE is empty" do
      it "returns false for comments and replies for all parent types" do
        expect(admin_post_comment.use_image_safety_mode?).to be_falsey
        expect(chapter_comment.use_image_safety_mode?).to be_falsey
        expect(tag_comment.use_image_safety_mode?).to be_falsey
        expect(admin_post_reply.use_image_safety_mode?).to be_falsey
        expect(chapter_reply.use_image_safety_mode?).to be_falsey
        expect(tag_reply.use_image_safety_mode?).to be_falsey
      end
    end

    context "when ArchiveConfig.PARENTS_WITH_IMAGE_SAFETY_MODE is set to something that doesn't match an existing parent type" do
      before { allow(ArchiveConfig).to receive(:PARENTS_WITH_IMAGE_SAFETY_MODE).and_return(["Work"]) }

      it "returns false for comments and replies for all parent types" do
        expect(admin_post_comment.use_image_safety_mode?).to be_falsey
        expect(chapter_comment.use_image_safety_mode?).to be_falsey
        expect(tag_comment.use_image_safety_mode?).to be_falsey
        expect(admin_post_reply.use_image_safety_mode?).to be_falsey
        expect(chapter_reply.use_image_safety_mode?).to be_falsey
        expect(tag_reply.use_image_safety_mode?).to be_falsey
      end
    end

    context "when ArchiveConfig.PARENTS_WITH_IMAGE_SAFETY_MODE is set to AdminPost" do
      before { allow(ArchiveConfig).to receive(:PARENTS_WITH_IMAGE_SAFETY_MODE).and_return(["AdminPost"]) }

      it "returns true for AdminPost comments and replies and false for Chapter and Tag comments and replies" do
        expect(admin_post_comment.use_image_safety_mode?).to be_truthy
        expect(admin_post_reply.use_image_safety_mode?).to be_truthy

        expect(chapter_comment.use_image_safety_mode?).to be_falsey
        expect(tag_comment.use_image_safety_mode?).to be_falsey
        expect(chapter_reply.use_image_safety_mode?).to be_falsey
        expect(tag_reply.use_image_safety_mode?).to be_falsey
      end
    end

    context "when ArchiveConfig.PARENTS_WITH_IMAGE_SAFETY_MODE is set to Chapter" do
      before { allow(ArchiveConfig).to receive(:PARENTS_WITH_IMAGE_SAFETY_MODE).and_return(["Chapter"]) }

      it "returns true for Chapter comments and false for AdminPost and Tag comments and replies" do
        expect(chapter_comment.use_image_safety_mode?).to be_truthy
        expect(chapter_reply.use_image_safety_mode?).to be_truthy

        expect(admin_post_comment.use_image_safety_mode?).to be_falsey
        expect(tag_comment.use_image_safety_mode?).to be_falsey
        expect(admin_post_reply.use_image_safety_mode?).to be_falsey
        expect(tag_reply.use_image_safety_mode?).to be_falsey
      end
    end

    context "when ArchiveConfig.PARENTS_WITH_IMAGE_SAFETY_MODE is set to Tag" do
      before { allow(ArchiveConfig).to receive(:PARENTS_WITH_IMAGE_SAFETY_MODE).and_return(["Tag"]) }

      it "returns true for Tag comments and replies and false for AdminPost and Chapter comments and replies" do
        expect(tag_comment.use_image_safety_mode?).to be_truthy
        expect(tag_reply.use_image_safety_mode?).to be_truthy

        expect(admin_post_comment.use_image_safety_mode?).to be_falsey
        expect(chapter_comment.use_image_safety_mode?).to be_falsey
        expect(admin_post_reply.use_image_safety_mode?).to be_falsey
        expect(chapter_reply.use_image_safety_mode?).to be_falsey
      end
    end

    context "when ArchiveConfig.PARENTS_WITH_IMAGE_SAFETY_MODE includes multiple parent types" do
      before { allow(ArchiveConfig).to receive(:PARENTS_WITH_IMAGE_SAFETY_MODE).and_return(%w[AdminPost Tag]) }

      it "returns true for comments and replies on the listed parent types and false for the other" do
        expect(admin_post_comment.use_image_safety_mode?).to be_truthy
        expect(tag_comment.use_image_safety_mode?).to be_truthy
        expect(admin_post_reply.use_image_safety_mode?).to be_truthy
        expect(tag_reply.use_image_safety_mode?).to be_truthy

        expect(chapter_comment.use_image_safety_mode?).to be_falsey
        expect(chapter_reply.use_image_safety_mode?).to be_falsey
      end
    end

    context "when the comment is from a guest" do
      let(:comment) { create(:comment, :by_guest) }

      it "returns true" do
        expect(comment.use_image_safety_mode?).to be_truthy
      end
    end
  end
end
