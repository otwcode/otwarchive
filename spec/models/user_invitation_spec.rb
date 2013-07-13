require 'spec_helper'

describe User do
  describe "User Accepts Invite" do
    before :all do
      @invite = create(:invitation)
      @user = create(:invited_user)
    end

    it "marks invitation redeemed"
    it "removes the user from invitation queue"
  end
end
