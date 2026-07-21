require "spec_helper"

describe AdminPostTag do
  describe ".delete_unused" do
    let!(:admin_post) { create(:admin_post) }
    let!(:tag) { create(:admin_post_tag) }

    context "when a tag is used on an admin post" do
      before do
        admin_post.admin_post_taggings.create!(admin_post_tag: tag)
      end

      it "does not delete the tag" do
        expect { AdminPostTag.delete_unused }
          .not_to change { AdminPostTag.count }
      end
    end

    context "when a tag is not used on any admin post" do
      it "deletes the tag" do
        expect { AdminPostTag.delete_unused }
          .to change { AdminPostTag.count }
          .by(-1)
        expect(AdminPostTag.find_by(name: tag.name)).to be_nil
      end
    end

    context "when both used and unused tags exist" do
      let!(:unused_tag) { create(:admin_post_tag) }

      before do
        admin_post.admin_post_taggings.create!(admin_post_tag: tag)
      end

      it "only deletes the unused tag" do
        expect { AdminPostTag.delete_unused }
          .to change { AdminPostTag.count }
          .by(-1)
        expect(AdminPostTag.find_by(name: tag.name)).to be_present
        expect(AdminPostTag.find_by(name: unused_tag.name)).to be_nil
      end
    end
  end
end
