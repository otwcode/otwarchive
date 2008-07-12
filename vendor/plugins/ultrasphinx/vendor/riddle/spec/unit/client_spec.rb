require 'spec/spec_helper'

describe Riddle::Client do
  it "should have the same keys for both commands and versions" do
    Riddle::Client::Commands.keys.should == Riddle::Client::Versions.keys
  end
  
  it "should default to localhost as the server" do
    Riddle::Client.new.server.should == "localhost"
  end
  
  it "should default to port 3312" do
    Riddle::Client.new.port.should == 3312
  end
  
  it "should translate anchor arguments correctly" do
    client = Riddle::Client.new
    client.set_anchor "latitude", 10.0, "longtitude", 95.0
    client.anchor.should == {
      :latitude_attribute   => "latitude",
      :latitude             => 10.0,
      :longtitude_attribute => "longtitude",
      :longtitude           => 95.0
    }
  end
  
  it "should add queries to the queue" do
    client = Riddle::Client.new
    client.queue.should be_empty
    client.append_query "spec"
    client.queue.should_not be_empty
  end
  
  it "should build a basic search message correctly" do
    client = Riddle::Client.new
    client.append_query "test "
    client.queue.first.should == query_contents(:simple)
  end
  
  it "should build a message with a specified index correctly" do
    client = Riddle::Client.new
    client.append_query "test ", "edition"
    client.queue.first.should == query_contents(:index)
  end
  
  it "should build a message using match mode :any correctly" do
    client = Riddle::Client.new
    client.match_mode = :any
    client.append_query "test this "
    client.queue.first.should == query_contents(:any)
  end
  
  it "should build a message using sort by correctly" do
    client = Riddle::Client.new
    client.sort_by = 'id'
    client.sort_mode = :extended
    client.append_query "testing "
    client.queue.first.should == query_contents(:sort)
  end
  
  it "should build a message using match mode :boolean correctly" do
    client = Riddle::Client.new
    client.match_mode = :boolean
    client.append_query "test "
    client.queue.first.should == query_contents(:boolean)
  end
  
  it "should build a message using match mode :phrase correctly" do
    client = Riddle::Client.new
    client.match_mode = :phrase
    client.append_query "testing this "
    client.queue.first.should == query_contents(:phrase)
  end
  
  it "should build a message with a filter correctly" do
    client = Riddle::Client.new
    client.filters << Riddle::Client::Filter.new("id", [10, 100, 1000])
    client.append_query "test "
    client.queue.first.should == query_contents(:filter)
  end
  
  it "should build a message with group values correctly" do
    client = Riddle::Client.new
    client.group_by       = "id"
    client.group_function = :attr
    client.group_clause   = "id"
    client.append_query "test "
    client.queue.first.should == query_contents(:group)
  end
  
  it "should build a message with group distinct value correctly" do
    client = Riddle::Client.new
    client.group_distinct = "id"
    client.append_query "test "
    client.queue.first.should == query_contents(:distinct)
  end
  
  it "should build a message with weights correctly" do
    client = Riddle::Client.new
    client.weights = [100, 1]
    client.append_query "test "
    client.queue.first.should == query_contents(:weights)
  end
  
  it "should build a message with an anchor correctly" do
    client = Riddle::Client.new
    client.set_anchor "latitude", 10.0, "longtitude", 95.0
    client.append_query "test "
    client.queue.first.should == query_contents(:anchor)
  end
  
  it "should keep multiple messages in the queue" do
    client = Riddle::Client.new
    client.weights = [100, 1]
    client.append_query "test "
    client.append_query "test "
    client.queue.length.should == 2
    client.queue.each { |item| item.should == query_contents(:weights) }
  end
  
  it "should keep multiple messages in the queue with different params" do
    client = Riddle::Client.new
    client.weights = [100, 1]
    client.append_query "test "
    client.weights = []
    client.append_query "test ", "edition"
    client.queue.first.should == query_contents(:weights)
    client.queue.last.should  == query_contents(:index)
  end
  
  it "should build a basic update message correctly" do
    client = Riddle::Client.new
    client.send(
      :update_message,
      "people",
      ["birthday"],
      {1 => [191163600]}
    ).should == query_contents(:update_simple)
  end
end