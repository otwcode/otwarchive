require "spec_helper"

describe CollectionQuery do
  it "allows you to perform a simple search" do
    q = CollectionQuery.new(title: "test")
    search_body = q.generated_query
    query = search_body[:query].first
    expect(query[1][:query]).to eq("test")
    expect(query[1][:default_operator]).to eq("AND")
  end

  it "sorts by created_at by default" do
    q = CollectionQuery.new
    expect(q.generated_query[:sort]).to eq([{ "created_at" => { order: "desc" } }, { "id" => { order: "desc" } }])
  end

  it "sorts by title" do
    q = CollectionQuery.new(sort_column: "title.keyword", sort_direction: "desc")
    expect(q.generated_query[:sort]).to eq([{ "title.keyword" => { order: "desc" } }, { "id" => { order: "desc" } }])
  end

  it "sorts by bookmarked items" do
    q = CollectionQuery.new(sort_column: "public_bookmarked_items_count", sort_direction: "desc")
    expect(q.generated_query[:sort]).to eq([{ "public_bookmarked_items_count" => { order: "desc" } }, { "id" => { order: "desc" } }])
  end

  it "sorts by works" do
    q = CollectionQuery.new(sort_column: "public_works_count", sort_direction: "desc")
    expect(q.generated_query[:sort]).to eq([{ "public_works_count" => { order: "desc" } }, { "id" => { order: "desc" } }])
  end

  it "sorts by general bookmarked items when logged in" do
    q = CollectionQuery.new(sort_column: "public_bookmarked_items_count", sort_direction: "desc", admin_logged_in: true)
    expect(q.generated_query[:sort]).to eq([{ "general_bookmarked_items_count" => { order: "desc" } }, { "id" => { order: "desc" } }])
  end

  it "sorts by general works when logged in" do
    q = CollectionQuery.new(sort_column: "public_works_count", sort_direction: "desc", admin_logged_in: true)
    expect(q.generated_query[:sort]).to eq([{ "general_works_count" => { order: "desc" } }, { "id" => { order: "desc" } }])
  end

  describe "filtering", collection_search: true do
    let!(:gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.current - 2.days, signups_close_at: Time.current + 1.week) }
    let!(:gift_exchange_collection) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }
    let!(:prompt_meme) { create(:prompt_meme, signup_open: true, signups_open_at: Time.current - 2.days, signups_close_at: Time.current + 1.week) }
    let!(:prompt_meme_collection) { create(:collection, challenge: prompt_meme, challenge_type: "PromptMeme") }
    let!(:signup_past_open) { create_invalid(:prompt_meme, signup_open: true, signups_open_at: Time.current - 2.days, signups_close_at: Time.current - 1.day) }
    let!(:signup_past_open_collection) { create(:collection, challenge: signup_past_open, challenge_type: "PromptMeme") }
    let!(:multifandom_collection) { create(:collection, multifandom: true) }

    let!(:fandom) { create(:canonical_fandom) }
    let!(:no_signup) { create(:collection, title: "no signup", collection_preference: create(:collection_preference, closed: true, moderated: true), tags: [fandom]) }

    let!(:participant) { create(:collection_participant, collection: prompt_meme_collection) }
    let!(:moderator) { create(:collection_participant, participant_role: CollectionParticipant::MODERATOR, collection: prompt_meme_collection) }
    let!(:item) do
      create(:collection_item, user_approval_status: "approved", collection_approval_status: "approved", work: create(:work, restricted: false), collection: prompt_meme_collection)
    end
    let!(:item2) do
      create(:collection_item, user_approval_status: "approved", collection_approval_status: "approved", work: create(:work, restricted: true), collection: gift_exchange_collection)
    end

    before do
      run_all_indexing_jobs
    end

    describe "by challenge_type" do
      it "shows only gift exchanges" do
        query = CollectionQuery.new(challenge_type: "GiftExchange")
        expect(query.search_results).to include gift_exchange_collection
        expect(query.search_results).not_to include prompt_meme_collection
      end

      it "shows only prompt memes" do
        query = CollectionQuery.new(challenge_type: "PromptMeme")
        expect(query.search_results).to include prompt_meme_collection
        expect(query.search_results).not_to include gift_exchange_collection
      end

      it "shows only collections without a challenge" do
        query = CollectionQuery.new(challenge_type: "no_challenge")
        expect(query.search_results).to include no_signup
        expect(query.search_results).to include multifandom_collection
        expect(query.search_results).not_to include prompt_meme_collection
        expect(query.search_results).not_to include gift_exchange_collection
      end
    end

    it "filters collections by title" do
      query = CollectionQuery.new(title: "no")
      expect(query.search_results).to include no_signup
      expect(query.search_results).not_to include prompt_meme_collection
      expect(query.search_results).not_to include gift_exchange_collection
      expect(query.search_results).not_to include multifandom_collection
    end

    it "filters collections by signup_open filter" do
      query = CollectionQuery.new(signup_open: true)
      expect(query.search_results).to include prompt_meme_collection
      expect(query.search_results).to include gift_exchange_collection
      expect(query.search_results).not_to include no_signup
      expect(query.search_results).not_to include signup_past_open_collection
    end

    it "filters collections by multifandom filter" do
      query = CollectionQuery.new(multifandom: true)
      expect(query.search_results).not_to include prompt_meme_collection
      expect(query.search_results).not_to include gift_exchange_collection
      expect(query.search_results).not_to include no_signup
      expect(query.search_results).to include multifandom_collection
    end

    it "filters collections by closed filter" do
      query = CollectionQuery.new(closed: true)
      expect(query.search_results).not_to include prompt_meme_collection
      expect(query.search_results).not_to include gift_exchange_collection
      expect(query.search_results).not_to include multifandom_collection
      expect(query.search_results).to include no_signup
    end

    it "filters collections by moderated filter" do
      query = CollectionQuery.new(moderated: true)
      expect(query.search_results).not_to include prompt_meme_collection
      expect(query.search_results).not_to include gift_exchange_collection
      expect(query.search_results).not_to include multifandom_collection
      expect(query.search_results).to include no_signup
    end

    it "filters collections by maintainer_id to get collections for owners and moderators" do
      query = CollectionQuery.new(maintainer_id: participant.pseud.user_id)
      expect(query.search_results).to include prompt_meme_collection
      expect(query.search_results).not_to include gift_exchange_collection
      expect(query.search_results).not_to include no_signup
      expect(query.search_results).not_to include multifandom_collection
    end

    it "filters collections by tags" do
      query = CollectionQuery.new(tag: fandom.name)
      expect(query.search_results).to include no_signup
      expect(query.search_results).not_to include prompt_meme_collection
      expect(query.search_results).not_to include gift_exchange_collection
      expect(query.search_results).not_to include multifandom_collection
    end
  end

  describe "#sort" do
    context "when no sort_direction is set" do
      %w[title.keyword signups_close_at].each do |column|
        context "when the sort column is set to #{column}" do
          it "sorts asc" do
            expect(CollectionQuery.new(sort_column: column).sort)
              .to eq([{ column => { order: "asc" } }, { "id" => { order: "asc" } }])
          end
        end
      end

      context "when the sort column is set to created_at" do
        it "sorts desc" do
          expect(CollectionQuery.new({ sort_column: "created_at" }).sort)
            .to eq([{ "created_at" => { order: "desc" } }, { "id" => { order: "desc" } }])
        end
      end
    end

    %w[asc desc].each do |sort_direction|
      context "when sort_direction is set to #{sort_direction}" do
        it "sorts #{sort_direction}" do
          expect(CollectionQuery.new(sort_direction: sort_direction).sort)
            .to eq([{ "created_at" => { order: sort_direction } }, { "id" => { order: sort_direction } }])
        end

        %w[created_at title.keyword signups_close_at].each do |column|
          context "when the sort column is set to #{column}" do
            it "returns #{sort_direction}" do
              expect(CollectionQuery.new(sort_column: column, sort_direction: sort_direction).sort)
                .to eq([{ column => { order: sort_direction } }, { "id" => { order: sort_direction } }])
            end
          end
        end
      end
    end
  end
end
