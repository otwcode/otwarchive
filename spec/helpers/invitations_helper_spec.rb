# frozen_string_literal: true

require "spec_helper"

describe InvitationsHelper do
  describe "#invitee_link" do
    let(:invitation) { create(:invitation) }

    context "when the invitee is an existing user" do
      let(:user) { create(:user) }

      before do
        invitation.update!(invitee: user)
      end

      it "returns a link to the user" do
        expect(helper.invitee_link(invitation)).to eq(link_to(user.login, user_path(user)))
      end
    end

    context "when the invitee is a deleted user" do
      let(:user) { create(:user) }

      before do
        invitation.update!(invitee: user)
        user.destroy!
        invitation.reload
      end

      it "returns a placeholder with the user ID" do
        expect(helper.invitee_link(invitation)).to eq("deleted user")
      end

      context "when logged in as an admin" do
        let(:admin) { build(:admin) }
        let!(:user_id) { user.id }

        before do
          User.current_user = admin
        end

        it "returns a placeholder with the user ID" do
          expect(helper.invitee_link(invitation)).to eq("deleted user (#{user_id})")
        end
      end
    end
  end
end
