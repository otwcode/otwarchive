require 'spec_helper'

describe BookmarkQuery do
  let(:collection) { build_stubbed(:collection) }
  let(:pseud) { build_stubbed(:pseud, user: user) }
  let(:tag) { build_stubbed(:tag) }
  let(:user) { build_stubbed(:user) }

  def find_parent_filter(query_list)
    query_list.find { |query| query.key? :has_parent }
  end

  it "allows you to perform a simple search" do
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

  it "excludes private bookmarks by default" do
    q = BookmarkQuery.new
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { private: "false" } })
  end

  it "excludes private bookmarks by default when a user is logged in" do
    User.current_user = user
    q = BookmarkQuery.new
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { private: "false" } })
  end

  it "includes private bookmarks when a user is logged in and looking at their own page" do
    User.current_user = user
    q = BookmarkQuery.new(parent: user)
    expect(q.generated_query.dig(:query, :bool, :filter)).not_to include({ term: { private: "false" } })
  end

  it "excludes hidden bookmarks" do
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
      expect(excluded_parent_filter.dig(:has_parent, :query, :bool, :should)).to \
        include({ term: { restricted: "true" } })
    end

    it "includes restricted works when logged in" do
      User.current_user = user
      expect(excluded_parent_filter.dig(:has_parent, :query, :bool, :should)).not_to \
        include({ term: { restricted: "true" } })
    end
  end

  it "allows you to filter for recs" do
    q = BookmarkQuery.new(rec: true)
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { rec: "true" } })
  end

  it "allows you to filter for bookmarks with notes" do
    q = BookmarkQuery.new(with_notes: true)
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { with_notes: "true" } })
  end

  it "allows you to filter for bookmarks by pseud" do
    q = BookmarkQuery.new(parent: pseud)
    expect(q.generated_query.dig(:query, :bool, :filter)).to include(terms: { pseud_id: [pseud.id] })
  end

  it "allows you to filter for bookmarks by user" do
    q = BookmarkQuery.new(parent: user)
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { user_id: user.id } })
  end

  it "allows you to filter for bookmarks by bookmark tags" do
    q = BookmarkQuery.new(tag_ids: [tag.id])

    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ term: { tag_ids: tag.id } })
  end

  it "allows you to filter for bookmarks by collection" do
    q = BookmarkQuery.new(parent: collection)
    expect(q.generated_query.dig(:query, :bool, :filter)).to include({ terms: { collection_ids: [collection.id] } })
  end

  context "when filtering on properties of the bookmarkable" do
    it "allows public word count filtering for guests by word_count" do
      q = BookmarkQuery.new(word_count: ">10")
      parent = find_parent_filter(q.generated_query.dig(:query, :bool, :must))
      expect(parent.dig(:has_parent, :query, :bool, :filter)).to \
        include({ range: { public_word_count: { gt: 10 } } })
    end

    it "allows public word count filtering for guests by words_from/to" do
      q = BookmarkQuery.new(words_from: "10", words_to: "15")
      parent = find_parent_filter(q.generated_query.dig(:query, :bool, :must))
      expect(parent.dig(:has_parent, :query, :bool, :filter)).to \
        include({ range: { public_word_count: { gte: 10, lte: 15 } } })
    end

    it "allows general word count filtering for registered users by word_count" do
      User.current_user = create(:user)
      q = BookmarkQuery.new(word_count: "<10")
      parent = find_parent_filter(q.generated_query.dig(:query, :bool, :must))
      expect(parent.dig(:has_parent, :query, :bool, :filter)).to \
        include({ range: { general_word_count: { lt: 10 } } })
    end

    it "allows general word count filtering for registered users by words_from/to" do
      User.current_user = create(:user)
      q = BookmarkQuery.new(words_from: "100", words_to: "450")
      parent = find_parent_filter(q.generated_query.dig(:query, :bool, :must))
      expect(parent.dig(:has_parent, :query, :bool, :filter)).to \
        include({ range: { general_word_count: { gte: 100, lte: 450 } } })
    end

    it "allows you to filter for complete works" do
      q = BookmarkQuery.new(complete: true)
      parent = find_parent_filter(q.generated_query.dig(:query, :bool, :must))
      expect(parent.dig(:has_parent, :query, :bool, :filter)).to \
        include({ term: { complete: "true" } })
    end

    it "allows you to filter by bookmarkable tags" do
      q = BookmarkQuery.new(parent: tag)
      parent = find_parent_filter(q.generated_query.dig(:query, :bool, :must))
      expect(parent.dig(:has_parent, :query, :bool, :filter)).to \
        include({ term: { filter_ids: tag.id } })
    end

    it "allows you to filter by bookmarkable language" do
      q = BookmarkQuery.new(language_id: "ig")
      parent = find_parent_filter(q.generated_query.dig(:query, :bool, :must))
      expect(parent.dig(:has_parent, :query, :bool, :filter)).to \
        include({ term: { "language_id.keyword": "ig" } })
    end
  end

  context "when sorting by properties of the bookmarkable" do
    it "allows sorting by public word count" do
      q = BookmarkQuery.new(sort_column: "word_count")
      # Sets sorting by score
      expect(q.generated_query[:sort]).to eq([{ _score: { order: "desc" } }, { id: { order: "desc" } }])
      # Computes score by public word count
      expect(q.generated_query.dig(:query, :bool, :must, :has_parent, :query, :function_score, :field_value_factor, :field)).to \
        eq("public_word_count")
    end

    it "allows sorting by general word count when logged in" do
      User.current_user = create(:user)
      q = BookmarkQuery.new(sort_column: "word_count")
      # Sets sorting by score
      expect(q.generated_query[:sort]).to eq([{ _score: { order: "desc" } }, { id: { order: "desc" } }])
      # Computes score by general word count
      expect(q.generated_query.dig(:query, :bool, :must, :has_parent, :query, :function_score, :field_value_factor, :field)).to \
        eq("general_word_count")
    end

    it "allows sorting by bookmarkable date" do
      q = BookmarkQuery.new(sort_column: "bookmarkable_date")
      expect(q.generated_query[:sort]).to eq([{ "bookmarkable_date" => { order: "desc", unmapped_type: "date" } }, { id: { order: "desc" } }])
    end
  end

  describe "a faceted query" do
    let(:bookmark_query) { BookmarkQuery.new(faceted: true) }
    let(:aggregations) { bookmark_query.generated_query[:aggs] }

    it "includes aggregations for the bookmark tags" do
      expect(aggregations[:tag]).to \
        include({ terms: { field: "tag_ids" } })
    end

    Tag::FILTERS.each do |type|
      it "includes #{type.underscore.humanize.downcase} aggregations for the bookmarkable" do
        expect(aggregations[:bookmarkable]).to \
          include({ parent: { type: "bookmark" } })

        expect(aggregations.dig(:bookmarkable, :aggs, type.underscore)).to \
          include({ terms: { field: "#{type.underscore}_ids" } })
      end
    end
  end
end
