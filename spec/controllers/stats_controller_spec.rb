require "spec_helper"

describe StatsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }

  describe "GET #index" do
    context "when logged in with posted works and series" do
      let!(:work) { create(:work, authors: [user.default_pseud], fandom_string: "Test Fandom") }
      let!(:series_work) { create(:work, authors: [user.default_pseud], fandom_string: "Series Fandom") }
      let!(:series) { create(:series, authors: [user.default_pseud], works: [series_work]) }

      before { fake_login_known_user(user) }

      it "includes the current user's posted works and series" do
        create(:work, authors: [create(:user).default_pseud])
        create(:work, authors: [user.default_pseud], posted: false)

        get :index, params: { user_id: user.login }

        listed = assigns(:works_and_series).values.flatten
        listed_works = listed.select { |item| item.type_label == "Work" }
        listed_series = listed.select { |item| item.type_label == "Series" }
        expect(listed_works.map(&:id)).to contain_exactly(work.id, series_work.id)
        expect(listed_series.map(&:id)).to contain_exactly(series.id)
      end

      describe "view types" do
        it "groups works and series by type label in type view" do
          get :index, params: { user_id: user.login, view_type: "type" }
          expect(assigns(:view_type)).to eq("type")
          expect(assigns(:works_and_series).keys).to contain_exactly("Work", "Series")
          expect(assigns(:works_and_series)["Work"].map(&:id)).to contain_exactly(work.id, series_work.id)
          expect(assigns(:works_and_series)["Series"].map(&:id)).to contain_exactly(series.id)
        end
      end

      describe "totals" do
        it "includes all of the expected total keys" do
          get :index, params: { user_id: user.login }
          expect(assigns(:totals).keys).to contain_exactly(
            :kudos, :comment_thread_count, :work_bookmarks, :work_subscriptions,
            :series_bookmarks, :series_subscriptions, :word_count, :hits, :user_subscriptions
          )
        end
        it "sums the bookmarks of the user's series" do
          create(:series_bookmark, bookmarkable_id: series.id)
          get :index, params: { user_id: user.login }
          expect(assigns(:totals)[:series_bookmarks]).to eq(1)
        end

        it "sums the private bookmarks of the user's series" do
          create(:series_bookmark, bookmarkable_id: series.id, private: true)
          get :index, params: { user_id: user.login }
          expect(assigns(:totals)[:series_bookmarks]).to eq(1)
        end

        it "sums the subscriptions of the user's series" do
          create(:subscription, subscribable: series)
          get :index, params: { user_id: user.login }
          expect(assigns(:totals)[:series_subscriptions]).to eq(1)
        end
      end
    end
  end
end
