require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe "Relevance::Tarantula::InvalidHtmlHandler" do
  before do
    @handler = Relevance::Tarantula::InvalidHtmlHandler.new
  end
    
  it "does not write HTML Scanner warnings to the console" do
    bad_html = "<html><div></form></html>"    
    err = Recording.stderr do
      @handler.handle(Relevance::Tarantula::Result.new(:response => stub(:html? => true, :body => bad_html)))
    end
    err.should == ""
  end
  
  it "rejects unclosed html" do
    response = stub(:html? => true, :body => '<html><div></html>', :code => 200)
    result = @handler.handle(Relevance::Tarantula::Result.new(:response => response))
    result.success.should == false
    result.description.should == "Bad HTML (Scanner)"
  end

  it "loves the good html" do
    response = stub(:html? => true, :body => '<html><div></div></html>', :code => 200)
    @handler.handle(Relevance::Tarantula::Result.new(:response => response)).should == nil
  end

  it "ignores non html" do
    response = stub(:html? => false, :body => '<html><div></html>', :code => 200)
    @handler.handle(Relevance::Tarantula::Result.new(:response => response)).should == nil
  end
end

