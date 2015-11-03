require 'spec_helper'
describe InviteRequest, :ready do
  describe "Validation" do

    context "Invalid email" do

      it "invitation is not created for a blank email" do
        @invite = build(:invite_request, email: nil)
        expect(@invite.save).to be_falsey
        expect(@invite.errors[:email]).not_to be_empty
      end

      BAD_EMAILS.each do |email|
        let(:bad_email) {build(:user, email: email)}
        it "cannot be created if the email does not pass veracity check" do
          expect(bad_email.save).to be_falsey
          expect(bad_email.errors[:email]).to include("should look like an email address.")
          expect(bad_email.errors[:email]).to include("does not seem to be a valid address.")
        end
      end
    end

  end
end