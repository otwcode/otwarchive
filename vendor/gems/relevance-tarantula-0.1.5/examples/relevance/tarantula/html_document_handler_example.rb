require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe "Relevance::Tarantula::HtmlDocumentHandler" do
  
  before do
    @handler = Relevance::Tarantula::HtmlDocumentHandler.new(nil)
  end
  
  it "does not write HTML Scanner warnings to the console" do
    bad_html = "<html><div></form></html>"    
    err = Recording.stderr do
      @handler.handle(Relevance::Tarantula::Result.new(:response => stub(:html? => true, :body => bad_html)))
    end
    err.should == ""
  end
  
  it "ignores non-html" do
    @handler.expects(:queue_link).never
    @handler.handle(Relevance::Tarantula::Result.new(:response => stub(:html? => false, :body => '<a href="/foo">foo</a>')))
  end
  
  it "queues anchor tags" do
    @handler.expects(:queue_link).with {|*args| args[0]['href'] == "/foo" && args[1] == nil}
    @handler.handle(Relevance::Tarantula::Result.new(:response => stub(:html? => true, :body => '<a href="/foo">foo</a>')))
  end

  it "queues link tags" do
    @handler.expects(:queue_link).with {|*args| args[0]['href'] == "/bar" && args[1] == nil}
    @handler.handle(Relevance::Tarantula::Result.new(:response => stub(:html? => true, :body => '<link href="/bar">bar</a>')))
  end
  
  it "queues forms" do
    @handler.expects(:queue_form).with{|tag,referrer| Hpricot::Elem === tag}
    @handler.handle(Relevance::Tarantula::Result.new(:url => "/page-url", :response => stub(:html? => true, :body => '<form>stuff</form>')))
  end
  
  it "infers form action from page url if form is not explicit" do
    @handler.expects(:queue_form).with{|tag,referrer| tag['action'].should == '/page-url'; true }
    @handler.handle(Relevance::Tarantula::Result.new(:url => "/page-url", :response => stub(:html? => true, :body => '<form>stuff</form>')))
  end
  
end

