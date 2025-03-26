require "spec_helper"

shared_examples "a wrangleable" do
  shared_examples "no wrangling activity recorded" do
    it "does not set a last wrangling time" do
      expect(wrangleable.save).to be_truthy
      expect(LastWranglingActivity.all).to be_empty
    end
  end

  describe "#update_last_wrangling_activity" do
    context "as a tag wrangler" do
      before do
        User.current_user = create(:tag_wrangler)
        User.current_user.last_wrangling_activity.updated_at = 60.days.ago
        User.current_user.last_wrangling_activity.save!(touch: false)
      end

      context "a wrangling activity has happened" do
        before { User.should_update_wrangling_activity = true }

        it "sets a last wrangling time" do
          freeze_time do
            expect(wrangleable.save).to be_truthy
            expect(User.current_user.reload.last_wrangling_activity.updated_at).to eq(Time.current)
          end
        end
      end

      context "no wrangling activity has happened" do
        before { User.should_update_wrangling_activity = false }

        it "does not set a new last wrangling time" do
          expect(wrangleable.save).to be_truthy
          expect(User.current_user.reload.last_wrangling_activity.updated_at).to be_within(1.minute).of 60.days.ago
        end
      end
    end
  end

  [
    ["regular user", FactoryBot.create(:user)],
    ["admin", FactoryBot.create(:admin)],
    ["nil", nil]
  ].each do |role, user|
    context "as #{role}" do
      before { User.current_user = user }

      context "a wrangling activity has happened" do
        before { User.should_update_wrangling_activity = true }

        include_examples "no wrangling activity recorded"
      end

      context "no wrangling activity has happened" do
        before { User.should_update_wrangling_activity = false }

        include_examples "no wrangling activity recorded"
      end
    end
  end
end

describe CommonTagging do
  let(:wrangleable) { build(:common_tagging) }

  it_behaves_like "a wrangleable"
end

describe MetaTagging do
  let(:wrangleable) { build(:meta_tagging) }

  it_behaves_like "a wrangleable"
end

describe Tag do
  let(:wrangleable) { build(:character) }

  it_behaves_like "a wrangleable"
end
