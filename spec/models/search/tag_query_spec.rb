require 'spec_helper'

describe TagQuery, type: :model do
  let!(:tags) do
    tags = {
      character: create(:character, name: "abc"),
      character2: create(:character, name: "abc -d"),
      character3: create(:character, name: "abc d"),
      fandom: create(:fandom, name: "abcd"),
      fandom2: create(:fandom, name: "abc-d"),
      fandom3: create(:fandom, name: "Yuri!!! On Ice"),
      freeform: create(:freeform, name: "abc+"),
      freeform2: create(:freeform, name: "abccc"),
      freeform3: create(:freeform, name: "ab'c d"),
      relationship: create(:relationship, name: "ab/cd"),
      relationship2: create(:relationship, name: "ab cd"),
      relationship3: create(:relationship, name: "ab \"cd\" ef")
    }
    update_and_refresh_indexes('tag')
    tags
  end

  it "performs a case-insensitive search ('AbC' matches 'abc')" do
    tag_query = TagQuery.new(name: "AbC")
    results = tag_query.search_results
    results.should include(tags[:character])
  end

  it "performs a query string search ('ab or cd' matches 'ab cd')" do
    tag_query = TagQuery.new(name: "ab OR cd")
    results = tag_query.search_results
    results.first.should be_in([tags[:relationship], tags[:relationship2]])
  end
  
  it "lists closest matches at the top of the results ('abc' result lists 'abc' or 'abc+' first)" do
    tag_query = TagQuery.new(name: "abc")
    results = tag_query.search_results
    results.first.should be_in([tags[:character], tags[:freeform]])
    results.should include(tags[:character2])
    results.should include(tags[:character3])
    results.should include(tags[:fandom2])
  end
  
  it "matches every token in any order ('d abc' matches 'abc d' and 'abc-d', but not 'abc' or 'abc+')" do
    tag_query = TagQuery.new(name: "d abc")
    results = tag_query.search_results
    results.should include(tags[:character3])
    results.should include(tags[:fandom2])
    results.should_not include(tags[:freeform])
    results.should_not include(tags[:character])
  end

  it "matches tokens with double quotes ('ab \"cd\" ef' matches 'ab \"cd\" ef')" do
    tag_query = TagQuery.new(name: "ab \"cd\" ef")
    results = tag_query.search_results
    results.should include(tags[:relationship3])
  end

  it "matches tokens with single quotes ('ab'c d' matches 'ab'c d')" do
    tag_query = TagQuery.new(name: "ab'c d")
    results = tag_query.search_results
    results.should include(tags[:freeform3])
  end
  
  it "performs a wildcard search at the end of a term ('abc*' matches 'abcd' and 'abcde')" do
    tag_query = TagQuery.new(name: "abc*")
    results = tag_query.search_results
    results.should include(tags[:character])
    results.should include(tags[:fandom])
    results.should include(tags[:freeform2])
    results.should_not include(tags[:relationship])
  end
  
  it "performs a wildcard search in the middle of a term ('a*d' matches 'abcd')" do
    tag_query = TagQuery.new(name: "a*d")
    results = tag_query.search_results
    results.should include(tags[:fandom])
  end
  
  it "performs a wildcard search at the beginning of a term ('*cd' matches 'abcd')" do
    tag_query = TagQuery.new(name: "*cd")
    results = tag_query.search_results
    results.should include(tags[:fandom])
  end
  
  it "preserves plus (+) character ('abc+' matches 'abc+' and 'abc', but not 'abccc')" do
    tag_query = TagQuery.new(name: "abc+")
    results = tag_query.search_results
    results.should include(tags[:freeform])
    results.should include(tags[:character])
    results.should_not include(tags[:freeform2])
  end
  
  it "preserves minus (-) character ('abc-d' matches 'abc-d', 'abc -d', 'abc d' but not 'abc' or 'abcd')" do
    tag_query = TagQuery.new(name: "abc-d")
    results = tag_query.search_results
    results.should include(tags[:fandom2])
    results.should include(tags[:character3])
    results.should_not include(tags[:fandom])
    results.should_not include(tags[:character])
  end

  it "preserves minus (-) preceded by a space ('abc -d' matches 'abc -d', 'abc d' and 'abc-d', but not 'abc')" do
    tag_query = TagQuery.new(name: "abc -d")
    results = tag_query.search_results
    results.first.should be_in([tags[:character2], tags[:character3]])
    results.should include(tags[:fandom2])
    results.should_not include(tags[:character])
  end
  
  it "preserves slashes without quotes ('ab/cd' should match 'ab/cd' and 'ab cd')" do
    tag_query = TagQuery.new(name: "ab/cd")
    results = tag_query.search_results
    results.should include(tags[:relationship])
    results.should include(tags[:relationship2])
  end
  
  it "matches tags with canonical punctuation ('yuri!!!' on ice matches 'Yuri!!! On Ice'" do
    tag_query = TagQuery.new(name: "yuri!!! on ice")
    results = tag_query.search_results
    results.should include(tags[:fandom3])
  end

  it "matches tags without canonical punctuation ('yuri' on ice matches 'Yuri!!! On Ice'" do
    tag_query = TagQuery.new(name: "yuri on ice")
    results = tag_query.search_results
    results.should include(tags[:fandom3])
  end
end
