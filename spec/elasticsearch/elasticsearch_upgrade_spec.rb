require 'spec_helper'

describe 'Elasticsearch' do

  before(:each) do
    deprecate_unless(!old_es?) do
      anon_collection.collection_preference.update(anonymous: true)

      anon_work.collections << anon_collection
      anon_work.save
      work.collections << collection
      work.save

      update_and_refresh_indexes('work')
    end
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
    deprecate_unless(!old_es?) do
      query = {"query" => "Game"}
      search = WorkSearchForm.new(query)

      expect(search.search_results).to include work
    end
  end

  it "should not find works that don't match" do
    deprecate_unless(!old_es?) do
      query = {"query" => "Game"}
      search = WorkSearchForm.new(query)

      expect(search.search_results).not_to include anon_work
    end
  end

  it "should find works that change authors" do
    deprecate_unless(!old_es?) do
      work.pseuds << create(:pseud, name: 'a new pseud name yay')
      update_and_refresh_indexes('work')

      search = WorkSearchForm.new({"query" => "yay"})

      expect(search.search_results).to include work
    end
  end

end
