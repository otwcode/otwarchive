require 'spec_helper'
describe InviteRequest do
  describe "Validation", :wip do

    context "email" do

      it "is exists" do
        @invite = build(:invite_request, email: nil)
        puts @invite.email
        @invite.save.should be_false
        @invite.errors[:email].should_not be_empty
      end

      it "is a valid email" do
        @invite = build(:invite_request, email: "fakey@crazy-z3d9df-domain.com")
        puts @invite.email
        @invite.save.should be_false
        @invite.errors[:email].should_not be_empty
      end
    end

  end
end