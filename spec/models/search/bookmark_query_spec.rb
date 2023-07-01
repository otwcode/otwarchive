require 'spec_helper'

describe BookmarkQuery do
  def find_parent_filter(query_list)
    query_list.find { |query| query.key? :has_parent }
  end

  it "should allow you to perform a simple search" do
    q = BookmarkQuery.new(bookmarkable_query: "space", bookmark_query: "unicorns")
    search_body = q.generated_query
    query = { query_string: { query: "unicorns", default_operator: "AND" } }
    expect(search_body[:query][:bool][:must]).to include(query)
    expect(search_body[:query][:bool][:must]).to include(
      has_parent: {
        parent_type: "bookmarkable",
        query: { query_string: { query: "space", default_operator: "AND" } },
        score: true
      }
    )
  end

  it "should not return private bookmarks by default" do
    q = BookmarkQuery.new
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { private: "false" } })
  end

  it "should not return private bookmarks by default when a user is logged in" do
    user = User.new
    user.id = 5
    User.current_user = user
    q = BookmarkQuery.new
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { private: "false" } })
  end

  it "should return private bookmarks when a user is logged in and looking at their own page" do
    user = User.new
    user.id = 5
    User.current_user = user
    q = BookmarkQuery.new(parent: user)
    expect(q.generated_query.dig(:query, :bool, :filter)).not_to include({ term: { private: "false" } })
  end

  it "should never return hidden bookmarks" do
    q = BookmarkQuery.new
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { hidden_by_admin: "false" } })
  end

  context "with empty search terms" do
    let(:query) { BookmarkQuery.new }

    let(:excluded_parent_filter) do
      find_parent_filter(query.generated_query.dig(:query, :bool, :must_not))
    end

    it "excludes bookmarks of hidden objects" do
      expect(excluded_parent_filter.dig(:has_parent, :query, :bool, :should)).to \
        include({ term: { hidden_by_admin: "true" } })
    end

    it "excludes bookmarks of drafts" do
      expect(excluded_parent_filter.dig(:has_parent, :query, :bool, :should)).to \
        include({ term: { posted: "false" } })
    end

    it "excludes restricted works when logged out" do
      User.current_user = nil
      expect(excluded_parent_filter.dig(:has_parent, :query, :bool, :should)).to \
        include({ term: { restricted: "true" } })
    end

    it "includes restricted works when logged in" do
      User.current_user = User.new
      expect(excluded_parent_filter.dig(:has_parent, :query, :bool, :should)).not_to \
        include({ term: { restricted: "true" } })
    end
  end

  it "should allow you to filter for recs" do
    q = BookmarkQuery.new(rec: true)
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { rec: "true" } })
  end

  it "should allow you to filter for bookmarks with notes" do
    q = BookmarkQuery.new(with_notes: true)
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { with_notes: "true" } })
  end

  it "should allow you to filter for bookmarks by pseud" do
    pseud = Pseud.new
    pseud.id = 42
    q = BookmarkQuery.new(parent: pseud)
    expect(q.generated_query.dig(:query, :bool, :filter)).to include(terms: { pseud_id: [42] })
  end

  it "should allow you to filter for bookmarks by user" do
    user = User.new
    user.id = 2
    q = BookmarkQuery.new(parent: user)
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { user_id: 2 } })
  end

  it "should allow you to filter for bookmarks by bookmark tags" do
    tag = Tag.new
    tag.id = 1
    q = BookmarkQuery.new(tag_ids: [1])

    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { tag_ids: 1 } })
  end

  it "should allow you to filter for bookmarks by collection" do
    collection = Collection.new
    collection.id = 5
    q = BookmarkQuery.new(parent: collection)
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ terms: { collection_ids: [5] } })
  end

  context "when filtering on properties of the bookmarkable" do
    it "allows you to filter for complete works" do
      q = BookmarkQuery.new(complete: true)
      parent = find_parent_filter(q.generated_query.dig(:query, :bool, :must))
      expect(parent.dig(:has_parent, :query, :bool, :filter)).to \
        include({ term: { complete: "true" } })
    end

    it "allows you to filter by bookmarkable tags" do
      tag = Tag.new
      tag.id = 1
      q = BookmarkQuery.new(parent: tag)
      parent = find_parent_filter(q.generated_query.dig(:query, :bool, :must))
      expect(parent.dig(:has_parent, :query, :bool, :filter)).to \
        include({ term: { filter_ids: 1 } })
    end

    it "allows you to filter by bookmarkable language" do
      q = BookmarkQuery.new(language_id: "ig")
      parent = find_parent_filter(q.generated_query.dig(:query, :bool, :must))
      expect(parent.dig(:has_parent, :query, :bool, :filter)).to \
        include({ term: { "language_id.keyword": "ig" } })
    end
  end
end
