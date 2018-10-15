require 'spec_helper'
require 'rake'

describe UsersController do
  include RedirectExpectationHelper

  def valid_user_attributes
    {
      email: "sna.foo@gmail.com", login: "myname", age_over_13: "1",
      terms_of_service: "1", password: "password"
    }
  end

  describe "create" do
    context "with valid parameters" do
      before do
        allow_any_instance_of(UsersController).to receive(:check_account_creation_status).and_return(true)
      end

      it "should be successful" do
        post :create, params: { user: valid_user_attributes }

        expect(response).to be_success
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to eq(User.last)
      end
    end

    context "when invitations are required to sign up" do
      let(:invitation) { create(:invitation) }

      before do
        AdminSetting.update_all(
          account_creation_enabled: true,
          creation_requires_invite: true,
          invite_from_queue_enabled: true
        )
      end

      context "signing up with no invitation" do
        it "redirects with an error" do
          post :create, params: { user: valid_user_attributes }

          it_redirects_to_with_error(
            invite_requests_path,
            "To create an account, you'll need an invitation. One option is " \
            "to add your name to the automatic queue below."
          )
        end
      end

      context "signing up with an invalid invitation" do
        it "redirects with an error" do
          post :create, params: { user: valid_user_attributes,
                                  invitation_token: "asdf" }

          it_redirects_to_with_error(
            new_feedback_report_path,
            "There was an error with your invitation token, please contact " \
            "support"
          )
        end
      end

      context "signing up with a valid invitation" do
        it "succeeds in creating the account" do
          post :create, params: { user: valid_user_attributes,
                                  invitation_token: invitation.token }

          expect(response).to be_success
          expect(assigns(:user)).to be_a(User)
          expect(assigns(:user)).to eq(User.last)
          expect(assigns(:user).login).to eq("myname")
        end
      end

      context "signing up with a used invitation" do
        let(:previous_user) { create(:user) }

        before do
          invitation.mark_as_redeemed(previous_user)
          previous_user.update_attributes(invitation_id: invitation.id)
        end

        it "redirects with an error" do
          post :create, params: { user: valid_user_attributes,
                                  invitation_token: invitation.token }

          it_redirects_to_with_error(
            root_path,
            "This invitation has already been used to create an account, " \
            "sorry!"
          )
        end

        context "when the previous user deletes their account" do
          it "redirects with an error" do
            previous_user.destroy

            post :create, params: { user: valid_user_attributes,
                                    invitation_token: invitation.token }

            it_redirects_to_with_error(
              root_path,
              "This invitation has already been used to create an account, " \
              "sorry!"
            )
          end
        end

        context "when the previous user's account was purged" do
          before do
            # Code for activating rake, adapted from
            # spec/miscellaneous/lib/tasks/resque.rake_spec.rb
            @rake = Rake.application
            @rake.init
            @rake.load_rakefile

            # Make sure the previous user's account fits the requirements to be
            # purged by the task:
            previous_user.update(activated_at: nil, created_at: 1.month.ago)
            @rake["admin:purge_unvalidated_users"].invoke
          end

          it "succeeds in creating the account" do
            post :create, params: { user: valid_user_attributes,
                                    invitation_token: invitation.token }

            expect(response).to be_success
            expect(assigns(:user)).to be_a(User)
            expect(assigns(:user)).to eq(User.last)
            expect(assigns(:user).login).to eq("myname")
          end
        end
      end
    end
  end
end
