require 'spec_helper'

describe BookmarkQuery do

  it "should allow you to perform a simple search" do
    q = BookmarkQuery.new(query: "unicorns")
    search_body = q.generated_query
    expect(search_body[:query][:filtered][:query][:bool][:must]).to eq([{:query_string=>{:query=>"unicorns"}}])
  end

  it "should not return private bookmarks by default" do
    q = BookmarkQuery.new
    expect(q.filters).to include({term: { private: 'F'} })
  end

  it "should not return private bookmarks by default when a user is logged in" do
    user = User.new
    user.id = 5
    User.current_user = user
    q = BookmarkQuery.new
    expect(q.filters).to include({term: { private: 'F'} })
  end

  it "should return private bookmarks when a user is logged in and looking at their own page" do
    user = User.new
    user.id = 5
    User.current_user = user
    q = BookmarkQuery.new(parent: user)
    expect(q.filters).not_to include({term: { private: 'F'} })
  end

  it "should never return hidden bookmarks" do
    q = BookmarkQuery.new
    expect(q.filters).to include({term: { hidden_by_admin: 'F'} })
  end

  it "should not return bookmarks of hidden objects" do
    q = BookmarkQuery.new
    expect(q.filters).to include({has_parent:{type: 'bookmarkable', filter:{term: {hidden_by_admin: 'F'}}}})
  end

  it "should not return restricted bookmarked works by default" do
    User.current_user = nil
    q = BookmarkQuery.new
    expect(q.filters).to include({has_parent:{type: 'bookmarkable', filter:{term: {restricted: 'F'}}}})
  end

  it "should only return restricted bookmarked works when a user is logged in" do
    User.current_user = User.new
    q = BookmarkQuery.new
    expect(q.filters).not_to include({has_parent:{type: 'bookmarkable', filter:{term: {restricted: 'F'}}}})
  end

  it "should allow you to filter for recs" do
    q = BookmarkQuery.new(rec: true)
    expect(q.filters).to include({term: { rec: 'T'} })
  end

  it "should allow you to filter for bookmarks with notes" do
    q = BookmarkQuery.new(with_notes: true)
    expect(q.filters).to include({term: { with_notes: 'T'} })
  end   

  it "should allow you to filter for complete works" do
    q = BookmarkQuery.new(complete: true)
    expect(q.filters).to include({has_parent:{type: 'bookmarkable', filter:{term: {complete: 'T'}}}})
  end

  it "should allow you to filter for bookmarks by pseud" do
    pseud = Pseud.new
    pseud.id = 42
    q = BookmarkQuery.new(parent: pseud)
    expect(q.filters).to include({terms: { pseud_id: [42]} })
  end

  it "should allow you to filter for bookmarks by user" do
    user = User.new
    user.id = 2
    q = BookmarkQuery.new(parent: user)
    expect(q.filters).to include({terms: { user_id: [2]} })
  end  

  it "should allow you to filter for bookmarks by bookmarkable tags" do
    tag = Tag.new
    tag.id = 1
    q = BookmarkQuery.new(parent: tag)
    expect(q.filters).to include({has_parent:{type: 'bookmarkable', filter:{terms: { execution: 'and', filter_ids: [1]} }}})
  end

  it "should allow you to filter for bookmarks by bookmark tags" do
    tag = Tag.new
    tag.id = 1
    q = BookmarkQuery.new(tag_ids: [1])
    expect(q.filters).to include({terms: { execution: 'and', tag_ids: [1]} })
  end

  it "should allow you to filter for bookmarks by collection" do
    collection = Collection.new
    collection.id = 5
    q = BookmarkQuery.new(parent: collection)
    expect(q.filters).to include({terms: { collection_ids: [5]} })
  end

  it "should allow you to filter for bookmarks by language" do
    q = BookmarkQuery.new(language_id: 1)
    expect(q.filters).to include({has_parent:{type: 'bookmarkable', filter:{term: {language_id: 1}}}})
  end

#   it "should allow you to filter by count ranges" do
#     q = WorkQuery.new(word_count: ">1000")
#     expect(q.filters).to include({range: { word_count: { gt: 1000 } } })
#   end

#   it "should sort by date by default" do
#     q = WorkQuery.new
#     expect(q.generated_query[:sort]).to eq({'revised_at' => { order: 'desc'}})
#   end

#   it "should allow you to sort by creator name" do
#     q = WorkQuery.new(sort_column: 'authors_to_sort_on', sort_direction: 'asc')
#     expect(q.generated_query[:sort]).to eq({'authors_to_sort_on' => { order: 'asc'}})
#   end

#   it "should allow you to sort by title" do
#     q = WorkQuery.new(sort_column: 'title_to_sort_on')
#     expect(q.generated_query[:sort]).to eq({'title_to_sort_on' => { order: 'desc'}})
#   end
  
#   it "should allow you to sort by kudos" do
#     q = WorkQuery.new(sort_column: 'kudos_count')
#     expect(q.generated_query[:sort]).to eq({'kudos_count' => { order: 'desc'}})
#   end
  
#   it "should allow you to sort by comments" do
#     q = WorkQuery.new(sort_column: 'comments_count')
#     expect(q.generated_query[:sort]).to eq({'comments_count' => { order: 'desc'}})
#   end

end