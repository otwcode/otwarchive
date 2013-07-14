require 'spec_helper'
describe InviteRequest do
  describe "Validation", :wip do

    context "Invalid email" do

      it "invitation is not created for a blank email" do
        @invite = build(:invite_request, email: nil)
        @invite.save.should be_false
        @invite.errors[:email].should_not be_empty
      end

      it "invitation is not created for an email that does not pass the veracity check" do
        @invite = build(:invite_request, email: "fakey@crazy-z3d9df-domain.com")
        puts @invite.email
        @invite.save.should be_false
        @invite.errors[:email].should_not be_empty
      end
    end

  end
end