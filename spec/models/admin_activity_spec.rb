require "spec_helper"

describe AdminActivity do
  it "has a valid factory" do
    expect(create(:admin_activity)).to be_valid
  end

  it "is invalid without an admin_id" do
    expect(build(:admin_activity, admin_id: nil).valid?).to be_falsey
  end

  describe ".target_name" do
    context "when target is a Pseud" do
      let(:pseud) { create(:pseud, name: "aka") }
      let!(:activity) { create(:admin_activity, target: pseud) }

      it "returns the pseud name and user login for existing pseud" do
        expect(activity.target_name).to eq("Pseud aka (#{pseud.user.login})")
      end

      it "returns the pseud ID for a deleted pseud" do
        pseud.destroy
        expect(activity.reload.target_name).to eq("Pseud #{pseud.id}")
      end
    end

    context "when target is a Work" do
      let(:work) { create(:work) }
      let(:activity) { create(:admin_activity, target: work) }

      it "returns the work ID" do
        expect(activity.target_name).to eq("Work #{work.id}")
      end
    end
  end
end
