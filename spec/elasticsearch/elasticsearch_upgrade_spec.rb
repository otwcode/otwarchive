require 'spec_helper'

describe 'Elasticsearch' do

  before(:each) do
    anon_collection.collection_preference.update(anonymous: true)

    anon_work.collections << anon_collection
    anon_work.save
    work.collections << collection
    work.save

    WorkIndexer.create_index unless $elasticsearch.indices.exists? index: 'ao3_test_works'
    indexer = WorkIndexer.new(Work.all.pluck(:id))
    indexer.index_documents
  end

  after(:each) do
    Work.destroy_all
    if $elasticsearch.indices.exists? 'ao3_test_works'
      $elasticsearch.indices.delete index: 'ao3_test_works'
    end
  end

  let!(:anon_collection) do
    FactoryGirl.create(:collection)
  end

  let!(:collection) do
    FactoryGirl.create(:collection)
  end

  let!(:anon_work) do
    FactoryGirl.create(:work, title: 'There and Back Again')
  end

  let!(:work) do
    FactoryGirl.create(:work, title: 'Game of Thrones')
  end


  it 'passes' do

    query = {"query" => "Anonymous"}
    search = WorkSearchForm.new(query)


  end


end
