require "spec_helper"

describe CollectionSearchForm, collection_search: true do
  describe "#process_options" do
    it "removes blank options" do
      options = { foo: nil, bar: "", baz: false, boo: true }
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
    let!(:collection) { create(:collection, id: 1, title: "test collection") }
    let!(:collection2) { create(:collection, id: 2, title: "not returned") }

    before(:each) do
      run_all_indexing_jobs
    end

    it "finds collections that match by title" do
      query = CollectionSearchForm.new(title: "test")
      expect(query.search_results).to include collection
      expect(query.search_results).not_to include collection2
    end
  end

  describe "sorting results" do
    describe "created_at sorting" do
      let!(:collection_1_year_ago) { create(:collection, created_at: Time.zone.now - 1.year, title: "collection_1_year_ago") }
      let!(:collection_now) { create(:collection, title: "collection_now") }
      let(:sorted_collection_titles) { %w[collection_now collection_1_year_ago] }

      before do
        run_all_indexing_jobs
      end

      it "sorts collections by created_at and desc by default" do
        collection_search = CollectionSearchForm.new
        expect(collection_search.search_results.map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by created_at and asc order" do
        collection_search = CollectionSearchForm.new(sort_direction: :asc)
        expect(collection_search.search_results.map(&:title)).to eq sorted_collection_titles.reverse
      end
    end

    describe "title sorting" do
      let!(:collection_1_year_ago) { create(:collection, title: "a_test") }
      let!(:collection_now) { create(:collection, title: "z_test") }
      let(:sorted_collection_titles) { %w[a_test z_test] }

      before do
        run_all_indexing_jobs
      end

      it "sorts collections by title and default asc order" do
        collection_search = CollectionSearchForm.new(sort_column: "title.keyword")
        expect(collection_search.search_results.map(&:title)).to eq sorted_collection_titles
      end

      it "sorts collections by title desc and desc order" do
        collection_search = CollectionSearchForm.new(sort_column: "title.keyword", sort_direction: :desc)
        expect(collection_search.search_results.map(&:title)).to eq sorted_collection_titles.reverse
      end
    end

    describe "signups_close_at sorting" do
      let!(:first_gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 1.week) }
      let!(:first_collection) { create(:collection, title: "first", challenge: first_gift_exchange, challenge_type: "GiftExchange") }
      let!(:second_gift_exchange) { create(:gift_exchange, signup_open: true, signups_open_at: Time.zone.now - 2.days, signups_close_at: Time.zone.now + 2.weeks) }
      let!(:second_collection) { create(:collection, title: "second", challenge: second_gift_exchange, challenge_type: "GiftExchange") }
      let(:sorted_collection_titles) { %w[first second] }

      before do
        run_all_indexing_jobs
      end

      it "sorts collections by title and default asc order" do
        collection_search = CollectionSearchForm.new(sort_column: "signups_close_at")
        expect(collection_search.search_results.map(&:title)).to eq sorted_collection_titles
      end
    end
  end

  describe "filters collection by parent_id" do
    let!(:parent) { create(:collection) }
    let!(:child) do
      build(:collection, parent_name: parent.name).tap do |c|
        c.save!(validate: false)
      end
    end

    before do
      run_all_indexing_jobs
    end

    it "filters all child collection of parent" do
      query = CollectionSearchForm.new(parent_id: parent.id)

      expect(query.search_results).to include(child)
      expect(query.search_results).not_to include(parent)
    end
  end

  describe "filter by tag" do
    let!(:collection) { create(:collection) }
    let(:tag) { create(:canonical_freeform) }

    before do
      collection.tags.push(tag)
      run_all_indexing_jobs
    end

    it "should only return collections in that collection" do
      search = CollectionSearchForm.new(tag: tag.name)
      expect(search.search_results).to include collection
    end

    context "when filtering by the canonical synonym of the tag" do
      let(:synonym) { create(:canonical_freeform) }
      let(:tag) { create(:freeform, merger: synonym) }

      it "returns collections with original tag" do
        search = CollectionSearchForm.new(tag: synonym.name)
        expect(search.search_results).to include collection
      end
    end

    context "when filtering by the meta tag of the tag" do
      let(:meta_tag) { create(:canonical_freeform) }
      let(:tag) { create(:canonical_freeform) }

      before do
        create(:meta_tagging, meta_tag: meta_tag, sub_tag: tag)
        run_all_indexing_jobs
      end

      it "returns collections with child tag" do
        search = CollectionSearchForm.new(tag: meta_tag.name)
        expect(search.search_results).to include collection
      end
    end
  end
end
