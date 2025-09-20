require "spec_helper"

describe CollectionsController, collection_search: true do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #index" do
    let!(:gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:gift_exchange_collection) do
      travel_to(2.seconds.ago) do
        create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange")
      end
    end
    let!(:prompt_meme) { create(:prompt_meme, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:prompt_meme_collection) do
      travel_to(1.second.ago) do
        create(:collection, challenge: prompt_meme, challenge_type: "PromptMeme")
      end
    end

    let!(:no_signup) { create(:collection, title: "no signup", collection_preference: create(:collection_preference, closed: true, moderated: true)) }

    let!(:participant) { create(:collection_participant, collection: prompt_meme_collection) }
    let!(:moderator) { create(:collection_participant, participant_role: CollectionParticipant::MODERATOR, collection: prompt_meme_collection) }
    let!(:item) do
      create(:collection_item, user_approval_status: "approved", collection_approval_status: "approved", work: create(:work, restricted: false), collection: prompt_meme_collection)
    end

    before do
      run_all_indexing_jobs
    end

    it "assigns subtitle with collection title and subcollections" do
      get :index, params: { collection_id: gift_exchange_collection.name }
      expect(assigns[:page_subtitle]).to eq("#{gift_exchange_collection.title} - Subcollections")
    end

    context "collections index" do
      it "includes all collections in index" do
        get :index
        expect(response).to have_http_status(:success)
        expect(assigns(:collections)).to include prompt_meme_collection
        expect(assigns(:collections)).to include gift_exchange_collection
        expect(assigns(:collections)).to include no_signup
      end

      describe "filters collections by challenge_type" do
        it "filters prompt memes" do
          get :index, params: { collection_search: { challenge_type: "PromptMeme" } }
          expect(response).to have_http_status(:success)
          expect(assigns(:collections)).to include prompt_meme_collection
          expect(assigns(:collections)).not_to include gift_exchange_collection
        end

        it "filters gift exchanges" do
          get :index, params: { collection_search: { challenge_type: "GiftExchange" } }
          expect(response).to have_http_status(:success)
          expect(assigns(:collections)).to include gift_exchange_collection
          expect(assigns(:collections)).not_to include prompt_meme_collection
        end
      end
    end

    context "sorting" do
      it "sorts collections by created_at DESC by default" do
        sorted_collection_titles = Collection.order("created_at DESC").map(&:title)

        get :index
        expect(response).to have_http_status(:success)
        expect(assigns(:collections).map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by created_at ASC" do
        sorted_collection_titles = Collection.order("created_at ASC").map(&:title)

        get :index, params: { collection_search: { sort_direction: "ASC" } }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections).map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by title, ASC by default" do
        sorted_collection_titles = Collection.order("title ASC").map(&:title)

        get :index, params: { collection_search: { sort_column: "title.keyword" } }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections).map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by title" do
        sorted_collection_titles = Collection.order("title DESC").map(&:title)

        get :index, params: { collection_search: { sort_column: "title.keyword", sort_direction: "DESC" } }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections).map(&:title)).to eq sorted_collection_titles
      end
    end

    it "collections index for user collections" do
      get :index, params: { user_id: moderator.pseud.user.login }

      expect(assigns(:collections)).to include prompt_meme_collection
      expect(assigns(:collections)).not_to include gift_exchange_collection
    end

    context "collections index for subcollections" do
      let!(:parent) { create(:collection) }
      let!(:child) { create_invalid(:collection, parent_name: parent.name) }

      before do
        run_all_indexing_jobs
      end

      it "filters all child collections of given collection" do
        get :index, params: { collection_id: parent.name }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections)).to include(child)

        expect(assigns(:collections)).not_to include parent
      end
    end

    context "denies access for work that isn't visible to user" do
      subject { get :index, params: { work_id: work } }
      let(:success) { expect(response).to render_template("index") }
      let(:success_admin) { success }

      include_examples "denies access for work that isn't visible to user"
    end

    context "denies access for restricted work to guest" do
      let(:work) { create(:work, restricted: true) }

      it "redirects with an error" do
        get :index, params: { work_id: work }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when indexing collections for an object" do
      context "when work does not exist" do
        it "raises an error" do
          expect do
            get :index, params: { work_id: 0 }
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when work exists" do
        let(:work) { create(:work) }

        it "renders the index" do
          get :index, params: { work_id: work.id }
          expect(response).to render_template :index
        end
      end

      context "when collection does not exist" do
        it "raises an error" do
          expect do
            get :index, params: { collection_id: "not_here" }
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when collection exists" do
        let(:collection) { create(:collection) }

        it "renders the index" do
          get :index, params: { collection_id: collection.name }
          expect(response).to render_template :index
        end
      end

      context "when user does not exist" do
        it "raises an error" do
          expect do
            get :index, params: { user_id: "not_here" }
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when user exists" do
        let(:user) { create(:user) }

        it "renders the index" do
          get :index, params: { user_id: user.login }
          expect(response).to render_template :index
        end
      end
    end
  end

  describe "challenges indexes" do
    let!(:gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:gift_exchange_collection) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }
    let!(:prompt_meme) { create(:prompt_meme, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:prompt_meme_collection) { create(:collection, challenge: prompt_meme, challenge_type: "PromptMeme") }

    before do
      run_all_indexing_jobs
    end

    context "displays all open challenges on list_challenges index" do
      it "includes all collections" do
        get :list_challenges
        expect(response).to have_http_status(:success)
        expect(assigns(:challenge_collections)).to include prompt_meme_collection
        expect(assigns(:challenge_collections)).to include gift_exchange_collection
      end
    end

    context "displays all open gift exchange challenges on list_ge_challenges index" do
      it "includes all gift exchanges" do
        get :list_ge_challenges
        expect(response).to have_http_status(:success)
        expect(assigns(:challenge_collections)).to include gift_exchange_collection
        expect(assigns(:challenge_collections)).not_to include prompt_meme_collection
      end
    end

    context "displays all open prompt meme challenges on list_pm_challenges index" do
      it "includes all collections" do
        get :list_pm_challenges
        expect(response).to have_http_status(:success)
        expect(assigns(:challenge_collections)).to include prompt_meme_collection
        expect(assigns(:challenge_collections)).not_to include gift_exchange_collection
      end
    end
  end

  describe "GET #show" do
    context "when collection does not exist" do
      it "raises an error" do
        expect do
          get :show, params: { id: "nonexistent" }
        end.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
