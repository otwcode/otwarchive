require 'spec_helper'

describe TagQuery, type: :model do

  it "should do something" do
    tag_query = TagQuery.new
    tag_query.name_query.should be_nil
  end

    # Note that the simple query string syntax only supports * at the end of a term; putting one at the start or in the middle of a search term does not work.
  it "searches for an exact match by default" do
    # abc should not match abcd
  end
  
  it "performs a wildcard search at the end of a term" do
    # abc* should match abcde
  end
  
  it "does NOT perform a wildcard search in the midd of a term" do
    # ab*d should not match abcd
  end
  
  it "does NOT perform a wildcard search at the beginning of a term" do
    # *bcd should not match abcd
  end
  
  it "should treat plus (+) as a literal character" do
    # abc+ should match abc+
    # abc+ should NOT match abcccc
  end
  
  it "should treat minus (-) as a literal character" do
    # ab-cd should match ab-cd
    # ab -cd should match ab -cd
    # ab -cd should NOT match ab (excluding cd)
  end
  
  it "should ignore slashes without quotes" do
    # a/b should match a b
  end
  
  it "should match slashes when they're quoted" do
    # 'a/b' should match a/b
  end
end
