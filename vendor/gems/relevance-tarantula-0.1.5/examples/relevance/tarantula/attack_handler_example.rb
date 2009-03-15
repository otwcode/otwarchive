require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe "Relevance::Tarantula::AttackHandler" do
  before do
    @handler = Relevance::Tarantula::AttackHandler.new
    attack = Relevance::Tarantula::Attack.new({:name => 'foo_name', :input => 'foo_code', :output => '<bad>'})
    @handler.stubs(:attacks).returns([attack])
  end
  
  it "lets safe documents through" do
    result = @handler.handle(Relevance::Tarantula::Result.new(:response => stub(:html? => true, :body => '<a href="/foo">good</a>')))
    result.should == nil
  end
  
  it "detects the supplied code" do
    result = @handler.handle(Relevance::Tarantula::Result.new(:response => stub(:html? => true, :body => '<a href="/foo"><bad></a>')))
    result.success.should == false
  end
end

describe "Attacks without an output specified" do
  it "never matches anything" do
    handler = Relevance::Tarantula::AttackHandler.new
    attack = Relevance::Tarantula::Attack.new({:name => 'foo_name', :input => 'foo_code'})
    Relevance::Tarantula::AttackFormSubmission.stubs(:attacks).returns([attack])
    result = handler.handle(Relevance::Tarantula::Result.new(:response => stub(:html? => true, :body => '<a href="/foo">good</a>')))
    result.should == nil
  end
end
