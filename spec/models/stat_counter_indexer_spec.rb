require 'spec_helper'

describe StatCounterIndexer do
  let(:work) { create(:work, title: "unique title") }
  let(:stat_counter) { work.stat_counter }

  describe "#index_documents" do
    before do
      stat_counter.update_attributes(
        kudos_count: 10,
        hit_count: 10,
        comments_count: 10,
        bookmarks_count: 10
      )
    end

    def result_count(options)
      WorkQuery.new(options).search_results.size
    end

    it "should update the search results for kudos" do
      expect do
        StatCounterIndexer.new([stat_counter.id]).index_documents
      end.to change { result_count(kudos_count: "> 5") }.from(0).to(1)
    end

    it "should update the search results for bookmarks" do
      expect do
        StatCounterIndexer.new([stat_counter.id]).index_documents
      end.to change { result_count(bookmarks_count: "> 5") }.from(0).to(1)
    end

    it "should update the search results for comments" do
      expect do
        StatCounterIndexer.new([stat_counter.id]).index_documents
      end.to change { result_count(comments_count: "> 5") }.from(0).to(1)
    end

    it "should update the search results for hit count" do
      expect do
        StatCounterIndexer.new([stat_counter.id]).index_documents
      end.to change { result_count(hits: "> 5") }.from(0).to(1)
    end

    it "should not change the search results for title" do
      expect do
        StatCounterIndexer.new([stat_counter.id]).index_documents
      end.to change { result_count(title: "unique title") }.from(0).to(1)
    end
  end
end

