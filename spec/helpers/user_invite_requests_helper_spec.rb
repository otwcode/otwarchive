require 'spec_helper'

describe UserInviteRequestsHelper do

  describe "link_to_previous_invite_requests" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @invitation_request1 = FactoryGirl.create(:user_invite_requests, user_id: @user.id)
      @invitation_request1.user.invitations.create
      @invitation_request2 = FactoryGirl.create(:user_invite_requests, user_id: @user.id)
      @invitation_request3 = FactoryGirl.create(:user_invite_requests, user_id: @user2.id)
    end

    context "users requesting an invitations" do
      it "should show '0' if no previous invitation request" do
        helper.link_to_previous_invite_requests(@invitation_request3).should eq "0"
      end
      it "should link to all previous invitation requests" do
        helper.link_to_previous_invite_requests(@invitation_request2).should eq "<a href=\"/admin/invitations/find?user_name=#{@user.login}\">1</a>"
      end
    end
  end
end