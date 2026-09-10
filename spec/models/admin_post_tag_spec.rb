require "spec_helper"

describe AdminPostTag do
  describe "destroy" do
    let(:admin_post_tag) { AdminPostTag.create!(name: "test-tag", language: Language.default) }
    let(:admin_post) { create(:admin_post) }

    before do
      admin_post.admin_post_taggings.create!(admin_post_tag: admin_post_tag)
    end

    it "destroys associated admin post taggings" do
      expect { admin_post_tag.destroy }
        .to change { AdminPostTagging.count }
        .by(-1)
    end

    it "does not destroy the admin post" do
      expect { admin_post_tag.destroy }
        .not_to change { AdminPost.count }
    end
  end
end
