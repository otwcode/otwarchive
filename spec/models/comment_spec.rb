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

  describe "#create" do
    context "as a tag wrangler" do
      let(:tag_wrangler) { create(:tag_wrangler) }

      shared_examples "updates last wrangling activity" do
        it "tracks last wrangling activity" do
          expect(tag_wrangler.last_wrangling_activity.updated_at).to be_within(10.seconds).of Time.now.utc
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
          expect(tag_wrangler.last_wrangling_activity).to be_nil
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
        let(:comment) do
          Timecop.travel(1.day.ago) do
            create(:comment, :on_tag, pseud: tag_wrangler.default_pseud)
          end
        end

        before { comment.comment_content = Faker::Lorem.sentence(word_count: 25) }

        it "does not update last wrangling activity" do
          expect(tag_wrangler.last_wrangling_activity.updated_at).not_to be_within(23.hours).of Time.now.utc
        end
      end
    end
  end

  describe "#destroy" do
    context "as a tag wrangler" do
      let(:tag_wrangler) { create(:tag_wrangler) }

      context "direct parent is a tag" do
        let(:comment) do
          Timecop.travel(1.day.ago) do
            create(:comment, :on_tag, pseud: tag_wrangler.default_pseud)
          end
        end

        before { comment.destroy }

        it "does not update last wrangling activity" do
          expect(tag_wrangler.last_wrangling_activity).not_to be_within(23.hours).of Time.now.utc
        end
      end
    end
  end
end
