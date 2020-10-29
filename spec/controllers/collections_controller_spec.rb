require "spec_helper"

describe CollectionsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #index" do
    let!(:gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:gift_exchange_collection) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }
    let!(:prompt_meme) { create(:prompt_meme, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:prompt_meme_collection) { create(:collection, challenge: prompt_meme, challenge_type: "PromptMeme") }

    let!(:no_signup) { create(:collection, title: "no signup", collection_preference: create(:collection_preference, closed: true, moderated: true)) }

    let!(:participant) { create(:collection_participant, collection: prompt_meme_collection) }
    let!(:moderator) { create(:collection_participant, participant_role: CollectionParticipant::MODERATOR, collection: prompt_meme_collection) }
    let!(:fandom) { create(:fandom) }
    let!(:item) {
      create(
        :collection_item, user_approval_status: CollectionItem::APPROVED, collection_approval_status: CollectionItem::APPROVED, 
        work: create(:work, restricted: false, fandoms: [fandom]), collection: prompt_meme_collection
      )
    }

    before(:each) do
      run_all_indexing_jobs
    end

    context "collections index" do
      it "includes all collections in index" do
        get :index
        expect(response).to have_http_status(:success)
        expect(assigns(:collections)).to include prompt_meme_collection
        expect(assigns(:collections)).to include gift_exchange_collection
        expect(assigns(:collections)).to include no_signup
      end

      it "filters collections by fandom" do
        get :index, params: { fandom: fandom.name }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections)).to include prompt_meme_collection
        expect(assigns(:collections)).not_to include gift_exchange_collection
      end

      describe "filters collections by challenge_type" do
        it "filters prompt memes" do
          get :index, params: { challenge_type: "PromptMeme" }
          expect(response).to have_http_status(:success)
          expect(assigns(:collections)).to include prompt_meme_collection
          expect(assigns(:collections)).not_to include gift_exchange_collection
        end

        it "filters gift exchanges" do
          get :index, params: { challenge_type: "GiftExchange" }
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

        get :index, params: { sort_direction: "ASC" }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections).map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by title, ASC by default" do
        sorted_collection_titles = Collection.order("title ASC").map(&:title)

        get :index, params: { sort_column: "title.keyword"}
        expect(response).to have_http_status(:success)
        expect(assigns(:collections).map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by title" do
        sorted_collection_titles = Collection.order("title DESC").map(&:title)

        get :index, params: { sort_column: "title.keyword", sort_direction: "DESC" }
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
      before do
        @parent = FactoryBot.create(:collection)
        # Temporarily set User.current_user to get past the collection
        # needing to be owned by same person as parent:
        User.current_user = @parent.owners.first.user
        @child = FactoryBot.create(:collection, parent_name: @parent.name)
        User.current_user = nil
        # reload the parent collection
        @parent.reload
  
        run_all_indexing_jobs
      end
  
      it "filters all child collections of given collection" do
        get :index, params: { collection_id: @parent.name }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections)).to include @child


        expect(assigns(:collections)).not_to include @parent
      end
    end
  end

  describe "challenges indexes" do
    let!(:gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:gift_exchange_collection) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }
    let!(:prompt_meme) { create(:prompt_meme, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:prompt_meme_collection) { create(:collection, challenge: prompt_meme, challenge_type: "PromptMeme") }

    before(:each) do
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
end
