require 'spec_helper'

describe CacheMaster do
 let(:cache_master) { CacheMaster.new(42) }

  it "should have a key" do
    cache_master.key.should == "works:42:assocs"
  end

  it "should record deleted associations" do
    cache_master.record('tag', 5)
    cache_master.get_hash.should == { "tag" => "5" }
  end

  it "should combine multiple deleted associations" do
    cache_master.record('tag', 6)
    cache_master.record('pseud', 7)
    cache_master.get_hash.should == { "tag" => "5,6", "pseud" => "7" }
  end

  it "should expire caches" do
    Tag.should_receive(:expire_ids).with(['5','6'])
    cache_master.expire
  end

  it "should not retain data after expiring caches" do
    cache_master.expire
    cache_master.get_hash.should == {}
  end

end