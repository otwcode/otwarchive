require 'spec_helper'

describe BookmarkableQuery do
  describe "#add_bookmark_filters" do
    it "should take a default has_parent query and flip it around" do
      bookmark_query = BookmarkQuery.new
      q = bookmark_query.bookmarkable_query
      excluded = q.generated_query.dig(:query, :bool, :must_not)
      expect(excluded).to include(term: { restricted: "true" })
      expect(excluded).to include(term: { hidden_by_admin: "true" })
      expect(excluded).to include(term: { posted: "false" })
    end

    it "should take bookmark filters and combine them into one child query" do
      bookmark_query = BookmarkQuery.new(user_ids: [5], excluded_bookmark_tag_ids: [666])
      q = bookmark_query.bookmarkable_query
      child_filter = q.bookmark_filter
      expect(child_filter.dig(:has_child, :query, :bool, :filter)).to include(term: { private: "false" })
      expect(child_filter.dig(:has_child, :query, :bool, :filter)).to include(term: { user_id: 5 })
      expect(child_filter.dig(:has_child, :query, :bool, :must_not)).to include(terms: { tag_ids: [666] })
    end
  end

  it "allows a guest to sort by guest-visible word count" do
    User.current_user = nil
    q = BookmarkQuery.new(sort_column: "word_count", sort_direction: "asc").bookmarkable_query
    expect(q.generated_query[:sort]).to eq([{ guest_visible_word_count: { order: "asc" } }, { sort_id: { order: "asc" } }])
  end

  it "allows a logged-in user to sort by total word count" do
    user = User.new
    user.id = 5
    User.current_user = user
    q = BookmarkQuery.new(sort_column: "word_count", sort_direction: "asc").bookmarkable_query
    expect(q.generated_query[:sort]).to eq([{ word_count: { order: "asc" } }, { sort_id: { order: "asc" } }])
  end

  it "allows a guest to filter by guest-visible word count" do
    User.current_user = nil
    q = BookmarkQuery.new(word_count: "10").bookmarkable_query
    expect(q.generated_query.dig(:query, :bool, :filter))
      .to include({ range: { guest_visible_word_count: { gte: 10, lte: 10 } } })
  end

  it "allows a logged-in user to filter by total word count" do
    user = User.new
    user.id = 5
    User.current_user = user
    q = BookmarkQuery.new(word_count: "10").bookmarkable_query
    expect(q.generated_query.dig(:query, :bool, :filter))
      .to include({ range: { word_count: { gte: 10, lte: 10 } } })
  end

  it "allows a guest to filter by guest-visible word count ranges" do
    User.current_user = nil
    q = BookmarkQuery.new(words_from: "500", words_to: "1000").bookmarkable_query
    expect(q.filters).to include({ range: { guest_visible_word_count: { gte: 500, lte: 1000 } } })
  end

  it "allows a logged-in user to filter by total word count ranges" do
    user = User.new
    user.id = 5
    User.current_user = user
    q = BookmarkQuery.new(words_from: "500", words_to: "1000").bookmarkable_query
    expect(q.filters).to include({ range: { word_count: { gte: 500, lte: 1000 } } })
  end
end
