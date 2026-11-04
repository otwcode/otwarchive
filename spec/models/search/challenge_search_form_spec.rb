require "spec_helper"

describe ChallengeSearchForm, collection_search: true do
  describe "#sort_options" do
    it "includes signups_close_at" do
      searcher = ChallengeSearchForm.new({})
      expect(searcher.sort_options).to include(["Date Sign-ups Close", "signups_close_at"])
    end
  end

  describe "#set_sorting" do
    it "sorts by signups_close_at by default" do
      searcher = ChallengeSearchForm.new({})
      expect(searcher.options[:sort_column]).to eq("signups_close_at")
    end

    it "sorts by signups_close_at descending by default" do
      searcher = ChallengeSearchForm.new({})
      expect(searcher.options[:sort_direction]).to eq("desc")
    end

    it "does not override provided sort column" do
      searcher = ChallengeSearchForm.new(sort_column: "title.keyword")
      expect(searcher.options[:sort_column]).to eq("title.keyword")
    end

    it "does not override provided sort direction" do
      searcher = ChallengeSearchForm.new(sort_column: "signups_close_at", sort_direction: "asc")
      expect(searcher.options[:sort_direction]).to eq("asc")
    end
  end

  describe "#default_sort_direction" do
    it "defaults to ascending for title" do
      searcher = ChallengeSearchForm.new(sort_column: "title.keyword")
      expect(searcher.default_sort_direction).to eq("asc")
    end

    it "defaults to descending for created_at" do
      searcher = ChallengeSearchForm.new(sort_column: "created_at")
      expect(searcher.default_sort_direction).to eq("desc")
    end

    it "defaults to descending for signups_close_at" do
      searcher = ChallengeSearchForm.new(sort_column: "signups_close_at")
      expect(searcher.default_sort_direction).to eq("desc")
    end
  end

  describe "sorting results" do
    let!(:first_gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
    let!(:first_collection) { create(:collection, title: "first", challenge: first_gift_exchange, challenge_type: "GiftExchange") }
    let!(:second_gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 2.weeks) }
    let!(:second_collection) { create(:collection, title: "second", challenge: second_gift_exchange, challenge_type: "GiftExchange") }

    before do
      run_all_indexing_jobs
    end

    it "sorts collections by signups_close_at descending by default" do
      searcher = ChallengeSearchForm.new(signup_open: true)
      expect(searcher.search_results.map(&:title)).to eq %w[second first]
    end
  end
end
