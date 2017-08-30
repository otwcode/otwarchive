require 'spec_helper'

describe 'Elasticsearch' do

  before(:each) do
    if $elasticsearch.indices.exists? index: 'ao3_test_works'
      $elasticsearch.indices.delete index: 'ao3_test_works'
    end

    anon_collection.collection_preference.update(anonymous: true)

    anon_work.collections << anon_collection
    anon_work.save
    work.collections << collection
    work.save

    WorkIndexer.create_index unless $elasticsearch.indices.exists? index: 'ao3_test_works'
    indexer = WorkIndexer.new(Work.all.pluck(:id))
    indexer.index_documents
  end

  let!(:anon_collection) do
    FactoryGirl.create(:collection)
  end

  let!(:collection) do
    FactoryGirl.create(:collection)
  end

  let!(:anon_work) do
    FactoryGirl.create(:work, title: 'There and Back Again', posted: true)
  end

  let!(:work) do
    FactoryGirl.create(:work, title: 'Game of Thrones', posted: true)
  end


  it "should find works that match" do
    query = {"query" => "Game"}
    search = WorkSearchForm.new(query)

    expect(search.search_results).to include work
  end

  it "should not find works that don't match" do
    query = {"query" => "Game"}
    search = WorkSearchForm.new(query)

    expect(search.search_results).not_to include anon_work
  end

  it "should find works that change authors" do
    work.pseuds << create(:pseud, name: 'a new pseud name yay')
    search = WorkSearchForm.new({"query" => "yay"})

    expect(search.search_results).to include work
  end

end
