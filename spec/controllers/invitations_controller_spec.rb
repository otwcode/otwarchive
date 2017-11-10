require "spec_helper"

describe InvitationsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "DELETE #destroy" do
    let(:invite) { create(:invitation, invitee_email: "") }
    let(:admin) { create(:admin) }

    it 'should display error on failure' do
      fake_login_admin(admin)

      allow(Invitation).to receive(:find).with(invite.id.to_s).and_return(invite)
      allow(invite).to receive(:destroy).and_return(false)

      delete :destroy, params: { id: invite.id }

      expect(Invitation).to have_received(:find)
      expect(invite).to have_received(:destroy)
      expect(flash[:error]).to eq("Invitation was not destroyed.")
    end
  end
end
