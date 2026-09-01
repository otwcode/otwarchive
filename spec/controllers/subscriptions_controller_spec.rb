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
      it_redirects_to_user_login_with_error
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

      it "sets no subscription type in page subtitle without type" do
        get :index, params: { user_id: user.login }
        expect(assigns[:page_subtitle]).to eq("#{user.login} - Subscriptions")
      end

      context "with valid subscription types in params" do
        %w[series works users].each do |sub_type|
          it "renders #{sub_type} subscriptions only" do
            get :index, params: { user_id: user.login, type: sub_type }

            expect(response).to render_template("index")
            expect(assigns(:subscribable_type)).to eq(sub_type)
            expect(assigns(:subscriptions).count).to eq(1)
          end

          it "sets #{sub_type} type in page subtitle" do
            get :index, params: { user_id: user.login, type: sub_type }
            expect(assigns[:page_subtitle]).to eq("#{user.login} - #{sub_type.classify} Subscriptions")
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

        it "sets no type in page subtitle" do
          get :index, params: { user_id: user.login, type: "Invalid" }  
          expect(assigns[:page_subtitle]).to eq("#{user.login} - Subscriptions")
        end
      end
    end
  end

  describe "POST #create" do
    before { fake_login_known_user(user) }

    context "when subscribing to a work" do
      let(:work) { create(:work) }

      it "creates a subscription and redirects with a success notice" do
        post :create, params: { user_id: user.login, subscription: { work_id: work.id } }
        expect(user.subscriptions.where(subscribable: work)).to exist
        expect(flash[:notice]).to include("You are now following #{work.title}")
      end
    end

    context "when subscribing to a series" do
      let(:series) { create(:series) }

      it "creates a subscription and redirects with a success notice" do
        post :create, params: { user_id: user.login, subscription: { series_id: series.id } }
        expect(user.subscriptions.where(subscribable: series)).to exist
        expect(flash[:notice]).to include("You are now following #{series.title}")
      end
    end

    context "when subscribing to a user" do
      let(:author) { create(:user) }

      it "creates a subscription and redirects with a success notice" do
        post :create, params: { user_id: user.login, subscription: { user_id: author.id } }
        expect(user.subscriptions.where(subscribable: author)).to exist
        expect(flash[:notice]).to include("You are now following #{author.login}")
      end
    end

    context "when no subscribable ID is provided" do
      it "returns 422" do
        post :create, params: { user_id: user.login, subscription: {} }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when multiple subscribable IDs are provided" do
      let(:work) { create(:work) }
      let(:series) { create(:series) }

      it "returns 422" do
        post :create, params: { user_id: user.login, subscription: { work_id: work.id, series_id: series.id } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the subscribable does not exist" do
      it "raises a not found error" do
        expect do
          post :create, params: { user_id: user.login, subscription: { work_id: -1 } }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when subscribable_type is provided instead of a type-specific ID" do
      let(:work) { create(:work) }

      it "returns 422 because the type param is ignored" do
        post :create, params: { user_id: user.login, subscription: { subscribable_type: "Work", subscribable_id: work.id } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.subscriptions).to be_empty
      end
    end

    context "when a browser-translated subscribable_type is sent alongside a valid ID" do
      let(:work) { create(:work) }

      it "ignores the translated type and creates the subscription" do
        post :create, params: { user_id: user.login, subscription: { work_id: work.id, subscribable_type: "用户" } }
        expect(user.subscriptions.where(subscribable: work)).to exist
      end
    end
  end

  describe "DELETE #destroy" do
    let(:work) { create(:work) }
    let!(:subscription) { create(:subscription, user: user, subscribable: work) }

    before { fake_login_known_user(user) }

    it "redirects with the work title in the success notice" do
      delete :destroy, params: { user_id: user.login, id: subscription.id }
      it_redirects_to_with_notice(user_subscriptions_path(user), "You have successfully unsubscribed from #{work.title}.")
    end

    context "when the work is in an unrevealed collection" do
      before { work.update!(collection_names: create(:unrevealed_collection).name) }

      it "redirects with 'Mystery Work' in the success notice" do
        delete :destroy, params: { user_id: user.login, id: subscription.id }
        it_redirects_to_with_notice(user_subscriptions_path(user), "You have successfully unsubscribed from Mystery Work.")
      end
    end
  end
end
