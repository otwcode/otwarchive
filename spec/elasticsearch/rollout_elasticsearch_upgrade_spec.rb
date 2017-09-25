require 'spec_helper'

describe 'Rolling out the upgrade' do

  describe 'the work model' do
    it 'should return new index name when use_new_search? is true' do
      Work.stub(:use_new_search?) { true }
      expect(Work.index_name).to eq("ao3_test_works")
    end

    it 'should return old inex name when use_new_search? is false' do
      Work.stub(:use_new_search?) { false }
      expect(Work.index_name).to eq("otwarchive_test_works")
    end
  end

  describe 'the bookmark model' do
    it 'should return new index name when use_new_search? is true' do
      Bookmark.stub(:use_new_search?) { true }
      expect(Bookmark.index_name).to eq('ao3_test_bookmarks')
    end

    it 'should return old index name when use_new_search? is false' do
      Bookmark.stub(:use_new_search?) { false }
      expect(Bookmark.index_name).to eq('otwarchive_test_bookmarks')
    end
  end

end
