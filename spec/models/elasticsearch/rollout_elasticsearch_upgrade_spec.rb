require 'spec_helper'

describe 'Rolling out the upgrade' do

  # The index_name functions on the models are used exclusivly by the old
  # indexer; the index_name functions on the Indexer classes are used
  # exclusively by the new indexer.
  describe "Work.index_name" do
    it "returns the old index name when use_new_search? is enabled" do
      Work.stub(:use_new_search?) { true }
      expect(Work.index_name).to eq("otwarchive_test_works")
    end

    it "returns the old index name when use_new_search? is disabled" do
      Work.stub(:use_new_search?) { false }
      expect(Work.index_name).to eq("otwarchive_test_works")
    end
  end

  describe "Bookmark.index_name" do
    it "returns the old index name when use_new_search? is enabled" do
      Bookmark.stub(:use_new_search?) { true }
      expect(Bookmark.index_name).to eq("otwarchive_test_bookmarks")
    end

    it "returns the old index name when use_new_search? is disabled" do
      Bookmark.stub(:use_new_search?) { false }
      expect(Bookmark.index_name).to eq("otwarchive_test_bookmarks")
    end
  end
end
