require "spec_helper"

describe AdminPost do
  describe ".disable_old_post_comments" do
    context "when the configured threshold is nil" do
      before do
        allow(ArchiveConfig)
          .to receive(:ADMIN_POST_COMMENTING_EXPIRATION_DAYS)
          .and_return(nil)
      end

      it "does not error" do
        expect { AdminPost.disable_old_post_comments }
          .not_to raise_error
      end
    end

    context "when the configured threshold is non-positive" do
      before do
        allow(ArchiveConfig)
          .to receive(:ADMIN_POST_COMMENTING_EXPIRATION_DAYS)
          .and_return(0)
      end

      it "does not update any posts" do
        post = create(:admin_post)

        AdminPost.disable_old_post_comments
        expect(post.reload.disable_all_comments?).to be(false)
      end
    end

    it "disables comments on a post outside the window" do
      old_post = travel_to(ArchiveConfig.ADMIN_POST_COMMENTING_EXPIRATION_DAYS.days.ago) do
        create(:admin_post)
      end

      AdminPost.disable_old_post_comments
      expect(old_post.reload.disable_all_comments?).to be(true)
    end

    it "does not disable comments on a post inside the window" do
      new_post = create(:admin_post)

      AdminPost.disable_old_post_comments
      expect(new_post.reload.disable_all_comments?).to be(false)
    end
  end

  describe "#translated_post_must_be_posted_first" do
    let(:admin_post) { create(:admin_post, :draft) }
    let(:translation) { create(:admin_post, :draft, translated_post_id: admin_post.id, language_id: create(:language).id) }

    it "returns error when posting a translation first" do
      translation.posted = true

      expect(translation.valid?).to be_falsey
      expect(translation.errors).to be_added(:translated_post_id, :must_be_posted_first)
    end
  end

  describe "#set_published_at" do
    before { freeze_time }

    let(:admin_post) { create(:admin_post, :draft) }

    it "sets the publication date to now" do
      admin_post.update!(posted: true)
      expect(admin_post.published_at).to eq(Time.current)
    end
    
    it "keeps existing publication dates" do
      admin_post.update!(posted: true, published_at: 1.day.ago)
      expect(admin_post.published_at).to eq(1.day.ago)
    end
  end

  describe "#post_translations" do
    let(:admin_post) { create(:admin_post, :draft) }
    let!(:translation) { create(:admin_post, :draft, translated_post_id: admin_post.id, language_id: create(:language).id) }

    it "posts draft translations" do
      admin_post.reload.update!(posted: true)
      expect(translation.reload.posted?).to be_truthy
      expect(translation.published_at).to eq(admin_post.published_at)
    end
  end
end
