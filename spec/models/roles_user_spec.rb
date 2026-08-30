require "spec_helper"

describe RolesUser do
  describe "add role" do
    context "tag_wrangler" do
      let(:user) { create(:user) }

      it "assigning the role sets last wrangler activity to now" do
        freeze_time do
          role = Role.find_or_create_by(name: "tag_wrangler")
          user.roles.push(role)
          expect(user.last_wrangling_activity).not_to be_nil
          expect(user.last_wrangling_activity.updated_at).to eq(Time.current)
        end
      end
    end
  end

  describe "remove role" do
    context "tag_wrangler" do
      let(:user) { create(:tag_wrangler) }

      it "clears last wrangler activity" do
        user.roles = []
        expect(LastWranglingActivity.find_by(user: user)).to be_nil
      end

      it "does not clear last wrangler activity for a different role" do
        other_role = Role.find_or_create_by(name: "archivist")
        user.roles.push(other_role)
        user.roles.delete(other_role)
        expect(user.last_wrangling_activity).not_to be_nil
      end
    end
  end
end
