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
      t = CollectionSearchForm.new(query: 'test')
      results = t.search_results
      expect(results).to include collection
    end

    it "finds works that match by name" do
      t = CollectionSearchForm.new(query: collection.name)
      results = t.search_results
      expect(results).to include collection
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
  end
end
