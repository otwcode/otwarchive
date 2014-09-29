require 'spec_helper'

describe IndexQueue do

  before(:each) do
    IndexQueue.all.each do |key|
      REDIS_GENERAL.del(key)
    end
  end

  it "should build correct keys" do
    IndexQueue.get_key('StatCounter', :stats).should == "index:stat_counter:stats"
  end

  it "should enqueue objects" do
    work = Work.new
    work.id = 34
    IndexQueue.enqueue(work, :background)
    IndexQueue.new("index:work:background").ids.should == ['34']
  end

  it "should enqueue ids" do
    IndexQueue.enqueue_id('Bookmark', 12, :background)
    IndexQueue.new("index:bookmark:background").ids.should == ['12']
  end

  it "should have ids added to it" do
    iq = IndexQueue.new("index:work:main")
    iq.add_id(1)
    iq.add_id(2)
    iq.ids.should == ['1', '2']
  end

  it "should create subqueues when run" do
    iq = IndexQueue.new("index:work:main")
    iq.add_id(1)
    IndexSubqueue.should_receive(:create_and_enqueue)
    iq.run

    IndexQueue::REDIS.exists("index:work:main").should be_false
  end

end