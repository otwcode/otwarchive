require "spec_helper"

describe SearchHelper do
  describe "#search_header" do
    let(:single_page_collection) do
      instance_double("SearchResults", total_pages: 1, total_entries: 1)
    end
    let(:paginated_collection) do
      instance_double(
        "SearchResults",
        total_pages: 3,
        total_entries: 40,
        unlimited_total_entries: 1_400,
        offset: 20,
        length: 20
      )
    end

    it "uses item-specific recent translations for unpaginated results" do
      expect(helper.search_header([:work], item_type: :work)).to eq("Recent Work")
      expect(helper.search_header([:work, :work], item_type: :work)).to eq("Recent Works")
    end

    it "uses item-specific count translations instead of pluralize guesses" do
      expect(helper.search_header(single_page_collection, item_type: :unposted_draft)).to eq("1 Unposted Draft")
    end

    it "uses the unlimited total for paginated range headers" do
      expect(helper.search_header(paginated_collection, item_type: :work)).to eq("21 - 40 of 1,400 Works")
    end

    it "assembles query and scope text through translations" do
      search = instance_double(WorkSearchForm, query: "coffee")
      user = create(:user, login: "creator")

      expect(helper.search_header(single_page_collection, item_type: :work, search: search, parent: user)).to eq("1 Work found by creator")
    end

    it "supports explicit query flags for non-search-form callers" do
      expect(helper.search_header(single_page_collection, item_type: :challenge_signup, query_present: true)).to eq("1 Sign-up found")
    end

    it "combines multiple scope phrases without hard-coded concatenation" do
      tag = create(:tag, name: "Alchemy")
      fandom = create(:fandom, name: "Dragon Age")

      expect(helper.search_header(single_page_collection, item_type: :bookmark, parent: tag, fandom: fandom))
        .to include(%(1 Bookmark in <a class="tag" href="/tags/Alchemy">Alchemy</a> in <a class="tag" href="/tags/Dragon%20Age">Dragon Age</a>))
    end
  end
end
