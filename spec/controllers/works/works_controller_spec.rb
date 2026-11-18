# frozen_string_literal: true

require "spec_helper"

describe WorksController, work_search: true do
  include LoginMacros
  include RedirectExpectationHelper

  describe "share" do
    it "returns a 404 response for unrevealed works" do
      unrevealed_collection = create :unrevealed_collection
      unrevealed_work = create :work, collections: [unrevealed_collection]
      get :share, params: { id: unrevealed_work.id }, xhr: true
      expect(response.status).to eq(404)
    end

    it "redirects to referer with an error for non-ajax warnings requests" do
      work = create(:work)
      referer = work_path(work)
      request.headers["HTTP_REFERER"] = referer
      get :share, params: { id: work.id }
      it_redirects_to_with_error(referer, "Sorry, you need to have JavaScript enabled for this.")
    end
  end

  describe "collected" do
    let(:collection) { create(:collection) }
    let(:collected_user) { create(:user) }

    it "returns not found error if user does not exist" do
      expect do
        get :collected, params: { user_id: "dummyuser" }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns not found error if no user is set" do
      expect do
        get :collected
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "with anonymous works" do
      let(:anonymous_collection) { create(:anonymous_collection) }

      let!(:work) do
        create(:work,
               authors: [collected_user.default_pseud],
               collection_names: collection.name)
      end

      let!(:anonymous_work) do
        create(:work,
               authors: [collected_user.default_pseud],
               collection_names: anonymous_collection.name)
      end

      before { run_all_indexing_jobs }

      it "does not return anonymous works in collections for guests" do
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work)
        expect(assigns(:works)).not_to include(anonymous_work)
      end

      it "does not return anonymous works in collections for logged-in users" do
        fake_login
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work)
        expect(assigns(:works)).not_to include(anonymous_work)
      end

      it "returns anonymous works in collections for the author" do
        fake_login_known_user(collected_user)
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work, anonymous_work)
      end

      it "returns anonymous works in collections for admins" do
        fake_login_admin(create(:admin))
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work, anonymous_work)
      end
    end

    context "with restricted works" do
      let(:collected_fandom) { create(:canonical_fandom) }
      let(:collected_fandom2) { create(:canonical_fandom) }

      let!(:unrestricted_work) do
        create(:work,
               authors: [collected_user.default_pseud],
               fandom_string: collected_fandom.name)
      end

      let!(:unrestricted_work_in_collection) do
        create(:work,
               authors: [collected_user.default_pseud],
               collection_names: collection.name,
               fandom_string: collected_fandom.name)
      end

      let!(:unrestricted_work_2_in_collection) do
        create(:work,
               authors: [collected_user.default_pseud],
               collection_names: collection.name,
               fandom_string: collected_fandom2.name)
      end

      let!(:restricted_work_in_collection) do
        create(:work,
               restricted: true,
               authors: [collected_user.default_pseud],
               collection_names: collection.name,
               fandom_string: collected_fandom.name)
      end

      before { run_all_indexing_jobs }

      context "as a guest" do
        it "renders the collected form" do
          get :collected, params: { user_id: collected_user.login }
          expect(response).to render_template("collected")
        end

        it "returns ONLY unrestricted works in collections" do
          get :collected, params: { user_id: collected_user.login }
          expect(assigns(:works)).to include(unrestricted_work_in_collection, unrestricted_work_2_in_collection)
          expect(assigns(:works)).not_to include(unrestricted_work, restricted_work_in_collection)
        end

        it "returns filtered works when search parameters are provided" do
          get :collected, params: { user_id: collected_user.login, work_search: { query: "fandom_ids:#{collected_fandom2.id}" } }
          expect(assigns(:works)).to include(unrestricted_work_2_in_collection)
          expect(assigns(:works)).not_to include(unrestricted_work_in_collection)
        end
      end

      context "with a logged-in user" do
        before { fake_login }

        it "returns ONLY works in collections" do
          get :collected, params: { user_id: collected_user.login }
          expect(assigns(:works)).to include(unrestricted_work_in_collection, restricted_work_in_collection)
          expect(assigns(:works)).not_to include(unrestricted_work)
        end
      end
    end

    context "with unrevealed works" do
      let(:unrevealed_collection) { create(:unrevealed_collection) }

      let!(:work) do
        create(:work,
               authors: [collected_user.default_pseud],
               collection_names: collection.name)
      end

      let!(:unrevealed_work) do
        create(:work,
               authors: [collected_user.default_pseud],
               collection_names: unrevealed_collection.name)
      end

      before { run_all_indexing_jobs }

      it "doesn't return unrevealed works in collections for guests" do
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work)
        expect(assigns(:works)).not_to include(unrevealed_work)
      end

      it "doesn't return unrevealed works in collections for logged-in users" do
        fake_login
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work)
        expect(assigns(:works)).not_to include(unrevealed_work)
      end

      it "returns unrevealed works in collections for the author" do
        fake_login_known_user(collected_user)
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work, unrevealed_work)
      end

      it "returns unrevealed works in collections for admins" do
        fake_login_admin(create(:admin))
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works)).to include(work, unrevealed_work)
      end
    end

    context "with sorting options" do
      let!(:new_work) do
        create(:work,
               title: "New Title",
               authors: [collected_user.default_pseud],
               collection_names: collection.name,
               created_at: 3.days.ago,
               revised_at: 3.days.ago)
      end

      let!(:old_work) do
        create(:work,
               title: "Old Title",
               authors: [collected_user.default_pseud],
               collection_names: collection.name,
               created_at: 30.days.ago,
               revised_at: 30.days.ago)
      end

      let!(:revised_work) do
        create(:work,
               title: "Revised Title",
               authors: [collected_user.default_pseud],
               collection_names: collection.name,
               created_at: 20.days.ago,
               revised_at: 2.days.ago)
      end

      before { run_all_indexing_jobs }

      it "sorts by date" do
        get :collected, params: { user_id: collected_user.login }
        expect(assigns(:works).map(&:title)).to eq([revised_work, new_work, old_work].map(&:title))
        get :collected, params: { user_id: collected_user.login, work_search: { sort_direction: "asc" } }
        expect(assigns(:works).map(&:title)).to eq([old_work, new_work, revised_work].map(&:title))
      end

      it "sorts by title" do
        get :collected, params: { user_id: collected_user.login, work_search: { sort_column: "title_to_sort_on" } }
        expect(assigns(:works).map(&:title)).to eq([new_work, old_work, revised_work].map(&:title))
        get :collected, params: { user_id: collected_user.login, work_search: { sort_column: "title_to_sort_on", sort_direction: "desc" } }
        expect(assigns(:works).map(&:title)).to eq([revised_work, old_work, new_work].map(&:title))
      end
    end
  end

  describe "GET #navigate" do
    context "denies access for work that isn't visible to user" do
      subject { get :navigate, params: { id: work.id } }
      let(:success) { expect(response).to render_template("navigate") }
      let(:success_admin) { success }

      include_examples "denies access for work that isn't visible to user"
    end

    context "denies access for restricted work to guest" do
      let(:work) { create(:work, restricted: true) }

      it "redirects with an error" do
        get :navigate, params: { id: work.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end
  end
end
