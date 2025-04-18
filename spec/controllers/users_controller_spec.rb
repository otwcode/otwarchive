require "spec_helper"

describe UsersController do
  include RedirectExpectationHelper
  include LoginMacros

  shared_examples "an action only authorized admins can access" do |authorized_roles:|
    before do
      fake_login_admin(admin)
    end

    context "when logged in as an admin with no role" do
      let(:admin) { create(:admin) }

      it "redirects with an error" do
        subject
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - authorized_roles).each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        it "redirects with an error" do
          subject
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    authorized_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        it "succeeds" do
          subject
          success
        end
      end
    end
  end

  shared_examples "blocks access for banned and suspended users" do
    context "when logged in as a banned user" do
      let(:user) { create(:user, banned: true) }

      before do
        fake_login_known_user(user)
      end

      it "redirects with an error" do
        subject
        it_redirects_to_simple(user_path(user))
        expect(flash[:error]).to match("Your account has been banned")
      end
    end

    context "when logged in as a suspended user" do
      let(:user) { create(:user, suspended: true, suspended_until: 1.week.from_now) }

      before do
        fake_login_known_user(user)
      end

      it "redirects with an error" do
        subject
        it_redirects_to_simple(user_path(user))
        expect(flash[:error]).to match("Your account has been suspended")
      end
    end
  end

  describe "GET #activate" do
    let(:user) { create(:user, confirmed_at: nil) }

    context "with no activation key" do
      it "redirects with an error" do
        get :activate, params: { id: "" }
        it_redirects_to_with_error(root_path, "Your activation key is missing.")
      end
    end

    context "with an invalid activation key" do
      it "redirects with an error" do
        get :activate, params: { id: "foobar" }
        it_redirects_to_with_error(root_path, "Your activation key is invalid. If you didn't activate within 14 days, your account was deleted. Please sign up again, or contact support via the link in our footer for more help.")
      end
    end

    context "with a used activation key" do
      before { user.activate }

      it "redirects with an error" do
        expect(user.active?).to be_truthy
        get :activate, params: { id: user.confirmation_token }
        it_redirects_to_with_error(user_path(user), "Your account has already been activated.")
      end
    end

    context "with a valid activation key" do
      it "activates the account and redirects with a success message" do
        expect(user.active?).to be_falsey
        get :activate, params: { id: user.confirmation_token }
        expect(user.reload.active?).to be_truthy
        it_redirects_to_with_notice(new_user_session_path, "Account activation complete! Please log in.")
      end
    end
  end

  describe "show" do
    let(:user) { create(:user) }

    context "with a valid username" do
      it "renders the show template" do
        get :show, params: { id: user }
        expect(response).to render_template(:show)
      end
    end

    context "with an invalid username" do
      it "raises an error" do
        expect do
          get :show, params: { id: "nobody" }
        end.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "GET #change_username" do
    let(:user) { create(:user) }
    let(:success) { expect(response).to render_template(:change_username) }
    subject { get :change_username, params: { id: user } }

    context "when logged in as a valid user" do
      before do
        fake_login_known_user(user)
      end

      it "shows the change username form" do
        subject
        success
      end
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: %w[superadmin policy_and_abuse]
    it_behaves_like "blocks access for banned and suspended users"
  end

  describe "POST #changed_username" do
    let(:user) { create(:user) }
    let(:new_username) { "foo1234" }
    let(:success) do
      expect(user.reload.login).to eq(new_username)
    end

    subject do
      post :changed_username, params: { id: user, new_login: new_username, password: user.password }
    end

    context "when logged in as a valid user" do
      before do
        fake_login_known_user(user)
      end

      it "updates the user's username" do
        subject
        success
      end
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: %w[superadmin policy_and_abuse] do
      # Non-exhaustive check that users who cannot access this page themselves (i.e. because  they are banned)
      # can still be renamed by an admin.
      let(:user) { create(:user, banned: true) }
      let(:new_username) { "user#{user.id}" }

      before do
        allow_any_instance_of(ZohoResourceClient).to receive(:find_ticket).and_return({
                                                                                        "status" => "Open",
                                                                                        "departmentId" => ""
                                                                                      })
      end

      subject do
        post :changed_username, params: { id: user, new_login: new_username, ticket_number: 123 }
      end
    end

    it_behaves_like "blocks access for banned and suspended users"
  end

  describe "destroy" do
    let(:user) { create(:user) }

    before do
      fake_login_known_user(user)
    end

    context "no log items" do
      it "successfully destroys and redirects with success message" do
        login = user.login
        delete :destroy, params: { id: login }
        it_redirects_to_with_notice(delete_confirmation_path, "You have successfully deleted your account.")
        expect(User.find_by(login: login)).to be_nil
      end
    end
  end
end
