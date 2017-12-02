require 'spec_helper'

describe WorkQuery do

  it "should return raw json for a simple search" do
    q = WorkQuery.new(query: "unicorns")
    search_body = q.generated_query
    expected_query_string_arr = [{
      query_string: {
        query: "unicorns",
        default_operator: "AND"
      }
    }]

    expect(search_body[:query][:bool][:must]).to eq(expected_query_string_arr)
  end

  it "should never return drafts" do
    q = WorkQuery.new
    expect(q.filters).to include({term: { posted: 'true'} })
  end

  it "should never return hidden works" do
    q = WorkQuery.new
    expect(q.filters).to include({term: { hidden_by_admin: 'false'} })
  end

  it "should not return unrevealed works by default" do
    q = WorkQuery.new
    expect(q.filters).to include({term: { in_unrevealed_collection: 'false'} })
  end

  it "should return unrevealed works when filtering by a collection" do
    q = WorkQuery.new(works_parent: Collection.new)
    expect(q.filters).not_to include({term: { in_unrevealed_collection: 'false'} })
  end

  it "should not return restricted works by default" do
    q = WorkQuery.new
    expect(q.filters).to include({term: { restricted: 'false'} })
  end

  it "should only return restricted works when a user is logged in" do
    User.current_user = User.new
    q = WorkQuery.new
    expect(q.filters).not_to include({term: { restricted: 'false'} })
  end

  it "should not return anonymous works when filtering by a pseud" do
    q = WorkQuery.new(works_parent: Pseud.new)
    expect(q.filters).to include({term: { in_anon_collection: 'false'} })
  end

  it "should not return anonymous works when filtering by a user" do
    q = WorkQuery.new(works_parent: User.new)
    expect(q.filters).to include({term: { in_anon_collection: 'false'} })
  end

  it "should allow you to filter for complete works" do
    q = WorkQuery.new(complete: true)
    expect(q.filters).to include({ term: { complete: true } })
  end

  it "should allow you to filter for works by tag" do
    tag = Tag.new
    tag.id = 1
    q = WorkQuery.new(works_parent: tag)
    #expect(q.filters).to include({terms: { execution: 'and', filter_ids: [1]} })
    expect(q.filters).to include({term: { filter_ids: 1}})
  end

  it "should allow you to filter for works by collection" do
    collection = Collection.new
    collection.id = 5
    q = WorkQuery.new(works_parent: collection)
    expect(q.filters).to include({terms: { collection_ids: [5]} })
  end

  it "should allow you to filter for works by pseud" do
    pseud = Pseud.new
    pseud.id = 42
    q = WorkQuery.new(works_parent: pseud, pseud_ids: [3])
    expect(q.filters).to include({terms: { pseud_ids: [3, 42]} })
  end

  it "should allow you to filter for works by user" do
    user = User.new
    user.id = 2
    q = WorkQuery.new(works_parent: user)
    expect(q.filters).to include({terms: { user_ids: [2]} })
  end

  it "should allow you to filter for works by tag ids" do
    tag = Tag.new
    tag.id = 6
    q = WorkQuery.new(filter_ids: [6])
    # expect(q.filters).to include({terms: { execution: 'and', filter_ids: [6]} })
    expect(q.filters).to include({term: { filter_ids: 6 }})
  end

  it "should allow you to exclude works by tag ids" do
    tag = FactoryGirl.create(:tag, name: "foobar", id: 6, canonical: true, type: 'Freeform')
    q = WorkQuery.new(excluded_tag_names: "foobar")
    search_body = q.generated_query
    expect(search_body[:query][:bool][:filter][:bool][:must_not]).to include({term: { filter_ids: 6} })
  end

  it "should allow you to filter for works by language" do
    q = WorkQuery.new(language_id: 1)
    expect(q.filters).to include({term: { language_id: 1} })
  end

  it "should allow you to filter for works with only one chapter" do
    q = WorkQuery.new(single_chapter: true)
    expect(q.filters).to include({term: { expected_number_of_chapters: 1} })
  end

  it "should allow you to filter for works by type" do
    q = WorkQuery.new(work_types: ['Text', 'Art'])
    expect(q.filters).to include({terms: { work_type: ['Text', 'Art']} })
  end

  it "should allow you to filter by count ranges" do
    q = WorkQuery.new(word_count: ">1000")
    expect(q.filters).to include({range: { word_count: { gt: 1000 } } })
  end

  it "should sort by date by default" do
    q = WorkQuery.new
    expect(q.generated_query[:sort]).to eq({'revised_at' => { order: 'desc', unmapped_type: 'date' }})
  end

  it "should allow you to sort by creator name" do
    q = WorkQuery.new(sort_column: 'authors_to_sort_on', sort_direction: 'asc')
    expect(q.generated_query[:sort]).to eq({'authors_to_sort_on' => { order: 'asc'}})
  end

  it "should allow you to sort by title" do
    q = WorkQuery.new(sort_column: 'title_to_sort_on')
    expect(q.generated_query[:sort]).to eq({'title_to_sort_on' => { order: 'desc'}})
  end

  it "should allow you to sort by kudos" do
    q = WorkQuery.new(sort_column: 'kudos_count')
    expect(q.generated_query[:sort]).to eq({'kudos_count' => { order: 'desc'}})
  end

  it "should allow you to sort by comments" do
    q = WorkQuery.new(sort_column: 'comments_count')
    expect(q.generated_query[:sort]).to eq({'comments_count' => { order: 'desc'}})
  end

  it "should rescue absurd dates" do
    q = WorkQuery.new(revised_at: "> 700000000 days")
    filter = q.range_filters.first
    date = filter.dig(:range, :revised_at, :lt)
    expect(date.year).to eq(1000.years.ago.year)
  end

  it "should rescue absurd date ranges" do
    q = WorkQuery.new(revised_at: "700000000-700000001 days ago")
    filter = q.range_filters.first
    start_date = filter.dig(:range, :revised_at, :gte)
    end_date = filter.dig(:range, :revised_at, :lte)
    expect(start_date.year).to eq(1000.years.ago.year)
    expect(end_date.year).to eq(1000.years.ago.year)
  end
end
