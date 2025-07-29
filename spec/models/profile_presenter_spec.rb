require "spec_helper"

describe ProfilePresenter do
  let(:user) { create(:user, email: "example@example.com") }
  let(:profile) { user.profile }
  let(:preference) { user.preference }
  let(:subject) { ProfilePresenter.new(profile) }

  describe "email" do
    context "for a user whose preference does not allow showing the email" do
      it "returns nil" do
        expect(subject.email).to be_nil
      end
    end

    context "for a user whose preference allows showing the email (legacy)" do
      before do
        allow(preference).to receive(:email_visible).and_return(true)
      end

      it "still returns nil" do
        expect(subject.email).to be_nil
      end
    end
  end

  describe "created_at" do
    it "returns the date part of the timestamp" do
      allow(user).to receive(:created_at).and_return(DateTime.new(2010, 12, 31, 10, 14, 20))
      expect(subject.created_at).to eq(Date.new(2010, 12, 31))
    end
  end

  describe "date_of_birth" do
    let(:date_of_birth) { Date.new(2000, 12, 31) }

    context "for a user whose preference does not allow showing date of birth" do
      before do
        allow(preference).to receive(:date_of_birth_visible).and_return(false)
      end

      it "returns nil" do
        profile.date_of_birth = date_of_birth
        expect(subject.date_of_birth).to be_nil
      end
    end

    context "for a user whose preference allows showing date of birth (legacy)" do
      before do
        allow(preference).to receive(:date_of_birth_visible).and_return(true)
      end

      it "still returns nil" do
        profile.date_of_birth = date_of_birth
        expect(subject.date_of_birth).to be_nil
      end

      it "still returns nil if it's not present" do
        profile.date_of_birth = nil
        expect(subject.date_of_birth).to be_nil
      end
    end
  end

  describe "location" do
    it "returns nil" do
      profile.location = "Anywhere"
      expect(subject.location).to be_nil
    end
  end
end
