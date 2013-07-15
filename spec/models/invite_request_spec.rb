require 'spec_helper'
describe InviteRequest, :ready do
  describe "Validation" do

    context "Invalid email" do

      it "invitation is not created for a blank email" do
        @invite = build(:invite_request, email: nil)
        @invite.save.should be_false
        @invite.errors[:email].should_not be_empty
      end

      BAD_EMAILS.each do |email|
        let(:bad_email) {build(:user, email: email)}
        it "cannot be created if the email does not pass veracity check" do
          bad_email.save.should be_false
          bad_email.errors[:email].should include("should look like an email address.")
          bad_email.errors[:email].should include("does not seem to be a valid address.")
        end
      end
    end

  end
end