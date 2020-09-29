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
    let!(:collection) { FactoryBot.create(:collection, id: 1) }

    # before(:each) do
    #   # run_all_indexing_jobs
    # end

    it "finds works that match" do
      t = CollectionSearchForm.new(title: collection.title)
      results = t.search_results

      binding.pry

      expect(results).to include collection
    end
  end
end
