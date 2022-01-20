require "spec_helper"

describe CommonTagging do
  shared_examples "updates last wrangling activity" do
    it "tracks last wrangling activity" do
      expect(User.current_user.last_wrangling_activity.updated_at).to be_within(10.seconds).of Time.now.utc
    end
  end

  shared_examples "does not update last wrangling activity" do
    it "does not last wrangling activity" do
      expect(LastWranglingActivity.all).to be_empty
    end
  end

  describe "#create" do
    let(:parent_tag) do
      Timecop.travel(1.year.ago) { create(:canonical_fandom) }
    end

    let(:child_tag) do
      Timecop.travel(1.year.ago) { create(:relationship) }
    end

    context "as tag wrangler" do
      before do
        User.current_user = create(:tag_wrangler)
        CommonTagging.create(common_tag: child_tag, filterable: parent_tag)
        User.current_user.reload
      end

      include_examples "updates last wrangling activity"
    end

    [
      ["regular user", FactoryBot.create(:user)],
      ["admin", FactoryBot.create(:admin)],
      ["nil", nil]
    ].each do |role, user|
      context "as #{role}" do
        before do
          User.current_user = user
          CommonTagging.create(common_tag: child_tag, filterable: parent_tag)
        end

        include_examples "does not update last wrangling activity"
      end
    end
  end

  describe "#update" do
    let(:common_tagging) do
      Timecop.travel(1.year.ago) { create(:common_tagging) }
    end

    context "as tag wrangler" do
      before do
        User.current_user = create(:tag_wrangler)
        common_tagging.update(filterable_type: "Tag")
        User.current_user.reload
      end

      include_examples "updates last wrangling activity"
    end

    [
      ["regular user", FactoryBot.create(:user)],
      ["admin", FactoryBot.create(:admin)],
      ["nil", nil]
    ].each do |role, user|
      context "as #{role}" do
        before do
          User.current_user = user
          common_tagging.update(filterable_type: "Tag")
        end

        include_examples "does not update last wrangling activity"
      end
    end
  end

  describe "#destroy" do
    let(:common_tagging) do
      Timecop.travel(1.year.ago) { create(:common_tagging) }
    end

    context "as tag wrangler" do
      before do
        User.current_user = create(:tag_wrangler)
        common_tagging.destroy
        User.current_user.reload
      end

      include_examples "updates last wrangling activity"
    end

    [
      ["regular user", FactoryBot.create(:user)],
      ["admin", FactoryBot.create(:admin)],
      ["nil", nil]
    ].each do |role, user|
      context "as #{role}" do
        before do
          User.current_user = user
          common_tagging.destroy
        end

        include_examples "does not update last wrangling activity"
      end
    end
  end
end
