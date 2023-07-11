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
end
