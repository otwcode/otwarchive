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
        expect(@invite.redeemed_at).not_to be_nil
      end
    end

    context "user requested an invitation" do
      before :all do
        @invite = create(:invitation)
        @user = create(:invited_user, invitation_token: @invite.token)
      end

      it "marks invitation redeemed" do
        @invite = Invitation.find_by_token(@invite.token)
        expect(@invite.redeemed_at).not_to be_nil
      end

      it "removes the user from invitation queue" do
        @invite_request = InviteRequest.find_by_email(@user.email)
        expect(@invite_request).to be_nil
      end
    end
  end

end
