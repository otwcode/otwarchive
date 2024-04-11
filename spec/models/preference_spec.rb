require "spec_helper"

describe Preference do
  it { is_expected.to allow_value("Test_Title-1 .,").for(:work_title_format) }
  it { is_expected.not_to allow_value("@; Test").for(:work_title_format) }
  it { is_expected.not_to allow_value("Sneaky\n\\").for(:work_title_format) }

  describe ".disable_work_skin?" do
    it "returns false for creator" do
      expect(Preference.disable_work_skin?("creator")).to be(false)
    end

    %w[light disable].each do |param|
      it "returns true for #{param}" do
        expect(Preference.disable_work_skin?(param)).to be(true)
      end
    end

    context "when the current user is a guest" do
      it "returns false" do
        expect(Preference.disable_work_skin?("foo")).to be(false)
      end
    end

    context "when the current user is registered" do
      let(:user) { create(:user) }

      before do
        User.current_user = user
      end

      it "returns false when the user's preference has skins enabled" do
        user.preference.update!(disable_work_skins: false)
        expect(Preference.disable_work_skin?("foo")).to be(false)
      end

      it "returns true when the user's preference has skins disabled" do
        user.preference.update!(disable_work_skins: true)
        expect(Preference.disable_work_skin?("foo")).to be(true)
      end
    end
  end
end
