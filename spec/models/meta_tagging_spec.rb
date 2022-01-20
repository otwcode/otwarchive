require "spec_helper"

describe MetaTagging do
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
    let(:meta_tag) do
      Timecop.travel(1.year.ago) { create(:fandom, canonical: true) }
    end

    let(:sub_tag) do
      Timecop.travel(1.year.ago) { create(:fandom, canonical: true) }
    end

    context "as tag wrangler" do
      before do
        User.current_user = create(:tag_wrangler)
        MetaTagging.create(meta_tag: meta_tag, sub_tag: sub_tag)
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
          MetaTagging.create(meta_tag: meta_tag, sub_tag: sub_tag)
        end

        include_examples "does not update last wrangling activity"
      end
    end
  end

  describe "#update" do
    let(:meta_tagging) do
      Timecop.travel(1.year.ago) { create(:meta_tagging) }
    end

    context "as tag wrangler" do
      before do
        User.current_user = create(:tag_wrangler)
        meta_tagging.update(direct: !meta_tagging.direct)
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
          meta_tagging.update(direct: !meta_tagging.direct)
        end

        include_examples "does not update last wrangling activity"
      end
    end
  end

  describe "#destroy" do
    let(:meta_tagging) do
      Timecop.travel(1.year.ago) { create(:meta_tagging) }
    end

    context "as tag wrangler" do
      before do
        User.current_user = create(:tag_wrangler)
        meta_tagging.destroy
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
          meta_tagging.destroy
        end

        include_examples "does not update last wrangling activity"
      end
    end
  end
end
