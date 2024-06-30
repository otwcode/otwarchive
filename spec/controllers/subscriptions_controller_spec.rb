require "spec_helper"

describe SubscriptionsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }

  describe "GET #index" do
    let(:author) { create(:user) }
    let(:work) { create(:work) }
    let(:series) { create(:series) }
    let!(:sub_series) { create(:subscription, user: user, subscribable: series) }
    let!(:sub_work) { create(:subscription, user: user, subscribable_type: "Work", subscribable_id: work.id) }
    let!(:sub_user) { create(:subscription, user: user, subscribable_type: "User", subscribable_id: author.id) }

    it "redirects to login when not logged in" do
      get :index, params: { user_id: user.login }
      it_redirects_to_with_error(new_user_session_path,
                                 "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    context "when logged in" do
      before { fake_login_known_user(user) }

      it "renders all subscriptions" do
        get :index, params: { user_id: user.login }
        expect(response).to render_template("index")
        expect(assigns(:subscriptions)).to contain_exactly(sub_series, sub_work, sub_user)
      end

      context "with invalid subscriptions" do
        let!(:subscription) { create(:subscription, user: user) }

        before do
          Subscription.update_all(subscribable_id: -1)
        end

        it "renders all subscriptions" do
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

      context "with valid subscription types in params" do
        %w[series works users].each do |sub_type|
          it "renders #{sub_type} subscriptions only" do
            get :index, params: { user_id: user.login, type: sub_type }

            expect(response).to render_template("index")
            expect(assigns(:subscribable_type)).to eq(sub_type)
            expect(assigns(:subscriptions).count).to eq(1)
          end
        end
      end

      context "with invalid subscription type in params" do
        it "renders all subscriptions" do
          get :index, params: { user_id: user.login, type: "Invalid" }

          expect(response).to render_template("index")
          expect(assigns(:subscribable_type)).to be_nil
          expect(assigns(:subscriptions)).to contain_exactly(sub_series, sub_work, sub_user)
        end
      end
    end
  end
end
