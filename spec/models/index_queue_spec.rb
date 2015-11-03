require 'spec_helper'

describe IndexQueue do

  before(:each) do
    IndexQueue.all.each do |key|
      REDIS_GENERAL.del(key)
    end
  end

  it "should build correct keys" do
    expect(IndexQueue.get_key('StatCounter', :stats)).to eq("index:stat_counter:stats")
  end

  it "should enqueue objects" do
    work = Work.new
    work.id = 34
    IndexQueue.enqueue(work, :background)
    expect(IndexQueue.new("index:work:background").ids).to eq(['34'])
  end

  it "should enqueue ids" do
    IndexQueue.enqueue_id('Bookmark', 12, :background)
    expect(IndexQueue.new("index:bookmark:background").ids).to eq(['12'])
  end

  it "should have ids added to it" do
    iq = IndexQueue.new("index:work:main")
    iq.add_id(1)
    iq.add_id(2)
    expect(iq.ids).to eq(['1', '2'])
  end

  it "should create subqueues when run" do
    iq = IndexQueue.new("index:work:main")
    iq.add_id(1)
    expect(IndexSubqueue).to receive(:create_and_enqueue)
    iq.run

    expect(IndexQueue::REDIS.exists("index:work:main")).to be_falsey
  end

end