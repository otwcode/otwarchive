require "spec_helper"

describe InviteRequestsController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  describe "GET #index" do
    it "renders" do
      get :index
      expect(response).to render_template("index")
      expect(assigns(:invite_request)).to be_a_new(InviteRequest)
    end
  end

  describe "GET #show" do
    context "given invalid emails" do
      it "redirects to index with error" do
        message = "You can search for the email address you signed up with below. If you can't find it, your invitation may have already been emailed to that address; please check your email Spam folder as your spam filters may have placed it there."
        get :show
        it_redirects_to_with_error(invite_requests_path, message)
        expect(assigns(:invite_request)).to be_nil
        get :show, email: "mistressofallevil@example.org"
        it_redirects_to_with_error(invite_requests_path, message)
        expect(assigns(:invite_request)).to be_nil
      end

      it "renders for an ajax call" do
        xhr :get, :show
        expect(response).to render_template("show")
        expect(assigns(:invite_request)).to be_nil
        xhr :get, :show, email: "mistressofallevil@example.org"
        expect(response).to render_template("show")
        expect(assigns(:invite_request)).to be_nil
      end
    end

    context "given valid emails" do
      let(:invite_request) { create(:invite_request) }

      it "renders" do
        get :show, email: invite_request.email
        expect(response).to render_template("show")
        expect(assigns(:invite_request)).to eq(invite_request)
      end

      it "renders for an ajax call" do
        xhr :get, :show, email: invite_request.email
        expect(response).to render_template("show")
        expect(assigns(:invite_request)).to eq(invite_request)
      end
    end
  end

  describe "POST #create" do
    it "redirects to index with error given invalid emails" do
      post :create, invite_request: { email: "wat" }
      expect(response).to render_template("index")
    end

    it "redirects to index with error given valid emails" do
      email = generate(:email)
      post :create, invite_request: { email: email }
      invite_request = InviteRequest.find_by_email(email)
      it_redirects_to_with_notice(invite_requests_path, "You've been added to our queue! Yay! We estimate that you'll receive an invitation around #{invite_request.proposed_fill_date}. We strongly recommend that you add do-not-reply@archiveofourown.org to your address book to prevent the invitation email from getting blocked as spam by your email provider.")
    end
  end

  describe "DELETE #destroy" do
    it "blocks non-admins" do
      delete :destroy
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")

      fake_login_known_user(user)
      delete :destroy
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      let(:invite_request) { create(:invite_request) }

      before { fake_login_admin(admin) }

      it "redirects to manage with notice" do
        delete :destroy, id: invite_request.id
        it_redirects_to_with_notice(manage_invite_requests_path, "Request was removed from the queue.")
      end

      it "redirects to manage at a specified page" do
        page = 45_789
        delete :destroy, id: invite_request.id, page: page
        it_redirects_to_with_notice(manage_invite_requests_path(page: page), "Request was removed from the queue.")
      end

      it "redirects to manage with error when deletion fails" do
        allow_any_instance_of(InviteRequest).to receive(:destroy) { false }
        delete :destroy, id: invite_request.id
        it_redirects_to_with_error(manage_invite_requests_path, "Request could not be removed. Please try again.")
      end

      xit "redirects to manage with error when request cannot be found" do
        # TODO: AO3-4971
        invite_request.destroy
        delete :destroy, id: invite_request.id
        # it_redirects_to_with_error(manage_invite_requests_path, "?")
      end
    end
  end

  describe "GET #manage" do
    it "blocks non-admins" do
      get :manage
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")

      fake_login_known_user(user)
      get :manage
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      let!(:invite_request_1) { create(:invite_request, position: 9001) }
      let!(:invite_request_2) { create(:invite_request, position: 2) }
      let!(:invite_request_3) { create(:invite_request, position: 7) }

      before { fake_login_admin(admin) }

      it "renders with invite requests in order" do
        get :manage
        expect(response).to render_template("manage")
        expect(assigns(:invite_requests)).to eq([invite_request_2, invite_request_3, invite_request_1])
      end
    end
  end

  describe "POST #reorder" do
    it "blocks non-admins" do
      post :reorder
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")

      fake_login_known_user(user)
      post :reorder
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      before { fake_login_admin(admin) }

      context "given invite requests out of order" do
        let!(:invite_request_1) { create(:invite_request, position: 9001) }
        let!(:invite_request_2) { create(:invite_request, position: 2) }
        let!(:invite_request_3) { create(:invite_request, position: 7) }

        it "redirects to manage with notice" do
          post :reorder
          it_redirects_to_with_notice(manage_invite_requests_path, "The queue has been successfully updated.")

          invite_request_1.reload
          invite_request_2.reload
          invite_request_3.reload

          # Positions corrected
          expect(InviteRequest.order(:position)).to eq([invite_request_2, invite_request_3, invite_request_1])
          expect(invite_request_1.position).to eq(3)
          expect(invite_request_2.position).to eq(1)
          expect(invite_request_3.position).to eq(2)
        end
      end

      it "redirects to manage with notice given no invite requests" do
        # with nothing to order, technically everything's in order
        expect(InviteRequest.count).to eq(0)
        post :reorder
        it_redirects_to_with_notice(manage_invite_requests_path, "The queue has been successfully updated.")
      end

      context "when the first invite request is already in the correct position" do
        let(:invite_request) { create(:invite_request) }

        it "redirects to manage with error" do
          expect(invite_request.position).to eq(1)
          post :reorder
          it_redirects_to_with_error(manage_invite_requests_path, "Something went wrong. Please try that again.")
        end
      end
    end
  end
end
