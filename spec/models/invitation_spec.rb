require 'spec_helper'

describe Invitation, :ready do

  describe "Create" do

    context "Create Invite with email" do

      let(:user) {build(:user)}
      let(:invite) {build(:invitation, invitee_email: user.email)}
      it "is created with an invitation token" do
        invite.save.should be_true
        invite.token.should_not be_nil
      end

    end

    context "Create Invite without email" do

      let(:user) {build(:user)}
      let(:invite) {build(:invitation, invitee_email: user.email)}
      it "is created with an invitation token" do
        invite.save.should be_true
        invite.token.should_not be_nil
      end

    end

    context "Create Invitation for existing user" do

      before(:each) do
        @user = create(:user)
      end

      let(:invite_for_existing) {build(:invitation, invitee_email: @user.email)}
      it "cannot be created" do
        invite_for_existing.save.should be_false
        invite_for_existing.recipient_is_not_registered.should be_false
      end
    end

    context "Create Invitation for invalid emails" do

      let(:bad_email) {build(:user, email: "fakey@crazy-z3d9df-domain.com")}
      it "cannot be created if the email does not pass veracity check" do
        bad_email.save.should be_false
        bad_email.errors[:invitee_email].should_not be_empty
      end
    end
  end

  describe "Update" do


    context "Update Invitation for existing user" do

      before(:all) do
        @invite = create(:invitation)
      end

      let(:user) {create(:user)}
      let(:invite_for_existing) {build(:invitation, invitee_email: user.email)}
      it "cannot be created" do
        invite_for_existing.save.should be_false
        invite_for_existing.recipient_is_not_registered.should be_false
      end
    end

    context "Create Invitation for invalid emails" do

      let(:bad_email) {build(:user, email: "fakey@crazy-z3d9df-domain.com")}
      it "cannot be created if the email does not pass veracity check" do
        bad_email.save.should be_false
        bad_email.errors[:invitee_email].should_not be_empty
      end
    end
  end
end