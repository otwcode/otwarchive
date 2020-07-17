# frozen_string_literal: true

require "spec_helper"

describe Comment do

  context "with an existing comment from the same user" do
    let(:first_comment) { create(:comment) }

    let(:second_comment) do
      attributes = %w[pseud_id commentable_id commentable_type comment_content name email]
      Comment.new(first_comment.attributes.slice(*attributes))
    end

    it "should be invalid if exactly duplicated" do
      expect(second_comment.valid?).to be_falsy
      expect(second_comment.errors.keys).to include(:comment_content)
    end

    it "should not be invalid if in the process of being deleted" do
      second_comment.is_deleted = true
      expect(second_comment.valid?).to be_truthy
    end
  end

  describe "#moderate_update?" do
    let(:work) { Work.new(id: 1) }
    let(:comment) do
      comment = build_stubbed(
        :guest_comment,
        comment_content: "hi there",
        unreviewed: false,
        commentable_id: 1
      )
      comment.commentable = work
      comment.parent = work
      comment
    end

    context "with moderation disabled" do
      before { work.moderated_commenting_enabled = false }

      context "with major changes to content" do
        before { comment.comment_content = "something completely different" }

        it "does not set unreviewed" do
          expect { comment.moderate_update }
            .not_to change { comment.unreviewed }
        end
      end
    end

    context "with moderation enabled" do
      before { work.moderated_commenting_enabled = true }

      context "with no changes to content" do
        it "does not reset unreviewed" do
          expect { comment.moderate_update }
            .not_to change { comment.unreviewed }
        end
      end

      context "with minor changes to content" do
        before { comment.comment_content = "hi there friend" }

        it "does not reset unreviewed" do
          expect { comment.moderate_update }
            .not_to change { comment.unreviewed }
        end
      end

      context "with more than a few different characters" do
        before { comment.comment_content = "hi there ya filthy animal" }

        it "resets unreviewed" do
          expect { comment.moderate_update }
            .to change { comment.unreviewed }
        end
      end

      context "with a creator comment" do
        it "does not reset unreviewed" do
          user = User.new(id: 12)
          pseud = Pseud.new(id: 13)
          pseud.user = user
          comment.pseud = pseud
          comment.comment_content = "something completely different"

          expect(user).to receive(:is_author_of?).and_return(true)
          expect { comment.moderate_update }
            .not_to change { comment.unreviewed }
        end
      end
    end
  end
end
