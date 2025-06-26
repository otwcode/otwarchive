require 'spec_helper'
describe InviteRequest do
  it "has a valid factory" do
    expect(build(:invite_request)).to be_valid
  end

  describe "Validation" do
    context "Invalid email" do
      it "invitation is not created for a blank email" do
        @invite = build(:invite_request, email: nil)
        expect(@invite.valid?).to be_falsey
        expect(@invite.errors[:email]).not_to be_empty
      end

      BAD_EMAILS.each do |email|
        it "cannot be created if the email does not pass format check" do
          bad_email = build(:user, email: email)
          expect(bad_email.valid?).to be_falsey
          expect(bad_email.errors[:email]).to include("should look like an email address.")
        end
      end
    end

    context "Duplicate email" do
      before :all do
        @original_request = create(:invite_request, email: "thegodthor@gmail.com")
      end

      it "should not let you sign up again with the same email" do
        dup_request = build(:invite_request, email: @original_request.email)
        expect(dup_request.valid?).to be_falsey
        expect(dup_request.errors[:email]).to include("is already part of our queue.")
      end

      it "should not allow duplicates with periods and plus signs" do
        dup_request = build(:invite_request, email: "the.god.thor+marvel@gmail.com")
        expect(dup_request.valid?).to be_falsey
        expect(dup_request.errors[:email]).to include("is already part of our queue.")
      end
    end
  end

  describe "#proposed_fill_time" do
    let(:invite_request) { create(:invite_request) }

    before do
      freeze_time

      admin_setting = AdminSetting.default
      admin_setting.invite_from_queue_number = 3
      admin_setting.invite_from_queue_frequency = 11
      admin_setting.save(validate: false)
    end

    it "returns time of next check for invite in next batch" do
      expect(invite_request.proposed_fill_time).to eq(Time.current + 11.hours)
    end

    it "returns time with x3 check duration for invite in 3rd batch" do
      allow(invite_request).to receive(:position).and_return(9)

      expect(invite_request.proposed_fill_time).to eq(Time.current + 33.hours)
    end
  end
end
