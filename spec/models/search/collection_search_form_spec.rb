require 'spec_helper'

describe CollectionSearchForm, collection_search: true do
  describe "#process_options" do
    it "removes blank options" do
      options = { foo: nil, bar: '', baz: false, boo: true }
      searcher = CollectionSearchForm.new(options)
      expect(searcher.options.keys).to include(:boo)
      expect(searcher.options.keys).not_to include(:foo, :bar, :baz)
    end
  end


  describe "#set_sorting" do
    it "does not override provided sort column" do
      options = { sort_column: "title" }
      searcher = CollectionSearchForm.new(options)
      expect(searcher.options[:sort_column]).to eq("title")
    end

    it "does not override provided sort direction" do
      options = { sort_direction: "asc" }
      searcher = CollectionSearchForm.new(options)
      expect(searcher.options[:sort_direction]).to eq("asc")
    end

    it "sorts by created_at by default" do
      searcher = CollectionSearchForm.new({})
      expect(searcher.options[:sort_column]).to eq("created_at")
    end
  end

  describe "searching" do
    let!(:collection) { FactoryBot.create(:collection, id: 1, title: 'test collection') }

    before(:each) do
      run_all_indexing_jobs
    end

    it "finds works that match by title" do
      query = CollectionSearchForm.new(query: 'test')
      expect(query.search_results).to include collection
    end

    it "finds works that match by name" do
      query = CollectionSearchForm.new(query: collection.name)
      expect(query.search_results).to include collection
    end
  end

  describe "sorting results" do
    describe "created_at sorting" do
      let!(:collection_1_year_ago) { create(:collection, created_at: Time.zone.now - 1.year, title: 'collection_1_year_ago') }
      let!(:collection_now) { create(:collection, title: 'collection_now') }
      let(:sorted_collection_titles) { ['collection_now', 'collection_1_year_ago'] }

      before(:each) do
        run_all_indexing_jobs
      end

      it "sorts collections by created_at and desc by default" do
        collection_search = CollectionSearchForm.new()
        expect(collection_search.search_results.map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by created_at and asc order" do
        collection_search = CollectionSearchForm.new(sort_direction: :asc)
        expect(collection_search.search_results.map(&:title)).to eq sorted_collection_titles.reverse
      end
    end

    describe "title sorting" do
      let!(:collection_1_year_ago) { create(:collection, title: 'a test') }
      let!(:collection_now) { create(:collection, title: 'z test') }
      let(:sorted_collection_titles) { ['a test', 'z test'] }

      before(:each) do
        run_all_indexing_jobs
      end

      it "sorts collections by title and default asc order" do
        collection_search = CollectionSearchForm.new(sort_column: 'title.keyword')
        expect(collection_search.search_results.map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by title desc and desc order" do
        collection_search = CollectionSearchForm.new(sort_column: 'title.keyword', sort_direction: :desc)
        expect(collection_search.search_results.map(&:title)).to eq sorted_collection_titles.reverse
      end
    end

    describe "signups_close_at sorting" do
      let!(:first_gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
      let!(:first_collection) { create(:collection, title: 'first', challenge: first_gift_exchange, challenge_type: "GiftExchange") }
      let!(:second_gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 2.weeks) }
      let!(:second_collection) { create(:collection, title: 'second', challenge: second_gift_exchange, challenge_type: "GiftExchange") }
      let(:sorted_collection_titles) { ['first', 'second'] }

      before(:each) do
        run_all_indexing_jobs
      end

      it "sorts collections by title and default asc order" do
        collection_search = CollectionSearchForm.new(sort_column: 'signups_close_at')
        expect(collection_search.search_results.map(&:title)).to eq sorted_collection_titles
      end
    end
  end

  describe "filtering" do
    let!(:gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:gift_exchange_collection) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }

    let!(:prompt_meme) { create(:prompt_meme, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:prompt_meme_collection) { create(:collection, challenge: prompt_meme, challenge_type: "PromptMeme") }

    let!(:no_signup) { create(:collection, title: 'no signup', collection_preference: create(:collection_preference, closed: true)) }

    let!(:participant) { create(:collection_participant, collection: prompt_meme_collection) }
    let!(:moderator) { create(:collection_participant, participant_role: CollectionParticipant::MODERATOR, collection: prompt_meme_collection) }
    let!(:fandom) { create(:fandom) }
    let!(:item) {
      create(
        :collection_item, user_approval_status: CollectionItem::APPROVED, collection_approval_status: CollectionItem::APPROVED, 
        work: create(:work, restricted: false, fandoms: [fandom]), collection: prompt_meme_collection
      )
    }
    let!(:item2) {
      create(
        :collection_item, user_approval_status: CollectionItem::APPROVED, collection_approval_status: CollectionItem::APPROVED, 
        work: create(:work, restricted: true, fandoms: [fandom]), collection: gift_exchange_collection
      )
    }

    before(:each) do
      run_all_indexing_jobs
    end

    describe "filters collections by challenge_type" do
      it "shows only gift exchanges" do
        query = CollectionSearchForm.new(challenge_type: 'GiftExchange')

        expect(query.search_results).to include gift_exchange_collection
        expect(query.search_results).not_to include prompt_meme_collection
      end

      it "shows only prompt memes" do
        query = CollectionSearchForm.new(challenge_type: 'PromptMeme')

        expect(query.search_results).to include prompt_meme_collection
        expect(query.search_results).not_to include gift_exchange_collection
      end
    end

    it "filter collections by signup_open_filter" do
      query = CollectionSearchForm.new(signup_open: true)
      expect(query.search_results).to include prompt_meme_collection
      expect(query.search_results).to include gift_exchange_collection
      expect(query.search_results).not_to include no_signup
    end

    it "filter collections by closed filter" do
      query = CollectionSearchForm.new(closed: true)
      expect(query.search_results).not_to include prompt_meme_collection
      expect(query.search_results).not_to include gift_exchange_collection
      expect(query.search_results).to include no_signup
    end

    it "filters on public_fandom_ids if user is not logged in" do
      query = CollectionSearchForm.new(fandom_ids: [fandom.id])

      expect(query.search_results).to include prompt_meme_collection
      expect(query.search_results).not_to include gift_exchange_collection
      expect(query.search_results).not_to include no_signup
    end

    it "filters on general_fandom_ids if user is logged in" do
      User.current_user = create(:user)
      query = CollectionSearchForm.new(fandom_ids: [fandom.id])

      expect(query.search_results).to include prompt_meme_collection
      expect(query.search_results).to include gift_exchange_collection
      expect(query.search_results).not_to include no_signup
    end

    it "filters collections by owner_ids" do  
      query = CollectionSearchForm.new(owner_ids: [participant.pseud.user_id])

      expect(query.search_results).to include prompt_meme_collection
      expect(query.search_results).not_to include gift_exchange_collection
      expect(query.search_results).not_to include no_signup
    end

    it "filters collections by moderator_ids" do
      query = CollectionSearchForm.new(moderator_ids: [moderator.pseud.user_id])

      expect(query.search_results).to include prompt_meme_collection
      expect(query.search_results).not_to include gift_exchange_collection
      expect(query.search_results).not_to include no_signup
    end
  end
end
