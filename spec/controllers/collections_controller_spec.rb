require 'spec_helper'

describe CollectionsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #index" do
    let!(:gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:gift_exchange_collection) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }
    let!(:prompt_meme) { create(:prompt_meme, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:prompt_meme_collection) { create(:collection, challenge: prompt_meme, challenge_type: "PromptMeme") }

    let!(:no_signup) { create(:collection, title: 'no signup', collection_preference: create(:collection_preference, closed: true, moderated: true)) }

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
        get :index, params: { collection_filters: { fandom_ids: [fandom.id] } }
        expect(response).to have_http_status(:success)
        expect(assigns(:collections)).to include prompt_meme_collection
      end

      describe "filters collections by challenge_type" do
        it "filters prompt memes" do
          get :index, params: { collection_filters: { challenge_type: 'PromptMeme' } }
          expect(response).to have_http_status(:success)
          expect(assigns(:collections)).to include prompt_meme_collection
          expect(assigns(:collections)).not_to include gift_exchange_collection
        end

        it "filters gift exchanges" do
          get :index, params: { collection_filters: { challenge_type: 'GiftExchange' } }
          expect(response).to have_http_status(:success)
          expect(assigns(:collections)).to include gift_exchange_collection
          expect(assigns(:collections)).not_to include prompt_meme_collection
        end

        it "filters collections with no challenges" do
          get :index, params: { collection_filters: { challenge_type: 'no_challenge' } }
          expect(response).to have_http_status(:success)
          expect(assigns(:collections)).to include no_signup
          expect(assigns(:collections)).not_to include gift_exchange_collection
          expect(assigns(:collections)).not_to include prompt_meme_collection
        end
      end
    end

    # # get children collections
      # it "excludes approved and invited items" do
      #   fake_login_known_user(owner)
      #   get :index, params: { collection_id: @collection.name, rejected: true }
      #   expect(assigns(:collection_items)).not_to include @approved_work_item
      #   expect(assigns(:collection_items)).not_to include @invited_work_item
      # end

      # # get user collections
      # it "excludes approved and invited items" do
      #   fake_login_known_user(owner)
      #   get :index, params: { collection_id: @collection.name, rejected: true }
      #   expect(assigns(:collection_items)).not_to include @approved_work_item
      #   expect(assigns(:collection_items)).not_to include @invited_work_item
      # end


      # list_challenges
      # list_ge_challenges
      # list_pm_challenges
  end
end
