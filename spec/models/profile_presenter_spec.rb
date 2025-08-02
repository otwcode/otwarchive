require "spec_helper"

describe ProfilePresenter do
  let(:user) { create(:user, email: "example@example.com") }
  let(:profile) { user.profile }
  let(:preference) { user.preference }
  let(:subject) { ProfilePresenter.new(profile) }

  describe "created_at" do
    it "returns the date part of the timestamp" do
      allow(user).to receive(:created_at).and_return(DateTime.new(2010, 12, 31, 10, 14, 20))
      expect(subject.created_at).to eq(Date.new(2010, 12, 31))
    end
  end
end
