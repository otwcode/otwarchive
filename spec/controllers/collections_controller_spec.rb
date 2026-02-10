require "spec_helper"

describe CollectionsController, collection_search: true do
  include LoginMacros
  include RedirectExpectationHelper

  describe "POST #create" do
    context "when the header_image_url is invalid" do
      it "fails validation but does not result in error 500" do
        fake_login
        post :create, params: { collection: attributes_for(:collection).merge(header_image_url: "This will error.") }
        # check that validation fails
        collection = assigns(:collection)
        expect(collection).not_to be_valid
        # check for the specific validation message
        expect(collection.errors[:header_image_url]).to include("is not a valid URL.")
        # but does not result in error 500
        expect(response.status).not_to be >= 500
      end
    end
  end

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
        create(:collection, challenge: prompt_meme, challenge_type: "PromptMeme", title: "Prompts for everyone")
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

      it "sorts collections by Works, DESC by default" do
        sorted_collection_titles = Collection.all.sort_by(&:public_works_count).reverse.map(&:title)

        get :index, params: { collection_search: { sort_column: "public_works_count" } }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections).map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by Works" do
        sorted_collection_titles = Collection.all.sort_by(&:public_works_count).map(&:title)

        get :index, params: { collection_search: { sort_column: "public_works_count", sort_direction: "ASC" } }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections).map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by Bookmarks, DESC by default" do
        sorted_collection_titles = Collection.all.sort_by(&:public_bookmarked_items_count).reverse.map(&:title)

        get :index, params: { collection_search: { sort_column: "public_bookmarked_items_count" } }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections).map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by Bookmarks" do
        sorted_collection_titles = Collection.all.sort_by(&:public_bookmarked_items_count).map(&:title)

        get :index, params: { collection_search: { sort_column: "public_bookmarked_items_count", sort_direction: "ASC" } }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections).map(&:title)).to eq sorted_collection_titles
      end
    end

    context "collections index for user collections" do
      it "includes only collections the user maintains" do
        get :index, params: { user_id: moderator.pseud.user.login }

        expect(assigns(:collections)).to include prompt_meme_collection
        expect(assigns(:collections)).not_to include gift_exchange_collection
      end

      context "with multiple maintained collections" do
        let!(:collection_a) { create(:collection, owner: moderator.pseud, title: "A collection", created_at: 2.minutes.ago) }
        let!(:collection_c) { create(:collection, owner: moderator.pseud, title: "C collection", created_at: 1.minute.ago) }
        let!(:collection_b) { create(:collection, owner: moderator.pseud, title: "B collection") }

        before do
          run_all_indexing_jobs
        end

        it "sorts by title ascending" do
          get :index, params: { user_id: moderator.pseud.user.login }

          expect(response).to have_http_status(:success)
          expect(assigns(:collections).map(&:title)).to eq ["A collection", "B collection", "C collection", "Prompts for everyone"]
        end
      end
    end

    context "collections index for subcollections" do
      let!(:parent) { create(:collection) }
      let!(:child) { create_invalid(:collection, parent_name: parent.name, title: "Subcollection") }

      before do
        run_all_indexing_jobs
      end

      it "filters all child collections of given collection" do
        get :index, params: { collection_id: parent.name }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections)).to include(child)

        expect(assigns(:collections)).not_to include parent
      end

      context "with multiple subcollections" do
        let!(:collection_a) { create_invalid(:collection, parent_name: parent.name, title: "A collection", created_at: 2.minutes.ago) }
        let!(:collection_c) { create_invalid(:collection, parent_name: parent.name, title: "C collection", created_at: 1.minute.ago) }
        let!(:collection_b) { create_invalid(:collection, parent_name: parent.name, title: "B collection") }

        before do
          run_all_indexing_jobs
        end

        it "sorts by title ascending" do
          get :index, params: { collection_id: parent.name }

          expect(response).to have_http_status(:success)
          expect(assigns(:collections).map(&:title)).to eq ["A collection", "B collection", "C collection", "Subcollection"]
        end
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
