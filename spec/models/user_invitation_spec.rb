require 'spec_helper'

describe User do

  describe "User Accepts Invite", :wip do
    context "user invited without invite request" do

      before :all do
        @invite = create(:invitation)
        @user = create(:invited_user, invitation_token: @invite.token)
      end

      it "marks invitation redeemed" do
        @invite = Invitation.find_by_token(@invite.token)
        @invite.redeemed_at.should_not be_nil
      end
    end

    context "user requested an invitation" do
      before :all do
        @invite = create(:invitation)
        @user = create(:invited_user, invitation_token: @invite.token)
      end

      it "marks invitation redeemed" do
        @invite = Invitation.find_by_token(@invite.token)
        @invite.redeemed_at.should_not be_nil
      end

      it "removes the user from invitation queue" do
        @invite_request = InviteRequest.find_by_email(@user.email)
        @invite_request.should be_nil
      end
    end
  end

end
