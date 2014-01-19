require 'spec_helper'

describe WorksOwner do
  
  before do
    @tag = Tag.new
    @tag.id = 666
    @time = "2013-09-27 19:14:18 -0400".to_datetime
    Delorean.time_travel_to @time
    @time = @time.to_i.to_s
  end
  
  describe "works_index_timestamp" do
    it "should set a timestamp for the owner when none exists and retrieve an existing one" do
      @tag.works_index_timestamp.should == @time
      @tag.works_index_timestamp.should == @time
    end
  end
  
  describe "works_index_cache_key" do
    it "should return the full cache key" do
      @tag.works_index_cache_key.should == "works_index_for_tag_666_#{@time}"
    end
    
    it "should accept a tag argument and return the tag's timestamp" do
      collection = Collection.new
      collection.id = 42
      collection.works_index_cache_key(@tag).should == "works_index_for_collection_42_tag_666_#{@time}"
    end
  end

end
