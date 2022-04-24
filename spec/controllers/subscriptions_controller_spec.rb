require 'spec_helper'

describe SubscriptionsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }

  describe "#index" do
    it "redirects to login when not logged in" do
      get :index, params: { user_id: user.login }
      it_redirects_to_with_error(new_user_session_path,
                                "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end
  end

  context "when logged in" do
    before { fake_login_known_user(user) }

    context "with valid subscriptions" do
      let(:author) { create(:user) }
      let(:work) { create(:work)}
      let(:series) { create(:series) }
      let!(:sub_series) { create(:subscription, user: user, subscribable_type: "Series", subscribable_id: series.id) }
      let!(:sub_work) { create(:subscription, user: user, subscribable_type: "Work", subscribable_id: work.id) }
      let!(:sub_user) { create(:subscription, user: user, subscribable_type: "User", subscribable_id: author.id) }

      it "renders the user subscriptions" do
        get :index, params: { user_id: user.login }
        expect(response).to render_template("index")
        expect(assigns(:subscriptions)).to satisfy { |subs| subs.size() == 3 }
      end
    end

    context "with invalid subscriptions" do
      let!(:subscription) { create(:subscription, user: user) }

      before do
        Subscription.update_all(subscribable_id: -1)
      end

      it "renders the user subscriptions" do
        get :index, params: { user_id: user.login }
        expect(response).to render_template("index")
        
        bad_sub = assigns(:subscriptions)[0]
        expect(bad_sub.subscribable_id).to eq(-1)
        expect(bad_sub.name).to eq("Deleted item")
      end

      it "allows deletion of invalid subscriptions" do
        get :index, params: { user_id: user.login }
        sub_id = assigns(:subscriptions)[0].id
        delete :destroy, params: { user_id: user.login, id: sub_id }
        it_redirects_to_with_notice(user_subscriptions_path(user), "You have successfully unsubscribed from Deleted item.")
      end
    end
  end
end
