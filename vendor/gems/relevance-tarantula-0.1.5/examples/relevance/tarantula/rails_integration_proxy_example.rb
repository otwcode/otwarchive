require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe "Relevance::Tarantula::RailsIntegrationProxy rails_integration_test" do
  before {
    Relevance::Tarantula::Crawler.any_instance.stubs(:crawl)
    Relevance::Tarantula::Crawler.any_instance.stubs(:rails_root).returns("STUB_RAILS_ROOT")
    Relevance::Tarantula::RailsIntegrationProxy.stubs(:rails_root).returns("STUB_RAILS_ROOT")
    Relevance::Tarantula::RailsIntegrationProxy.stubs(:new).returns(stub(:integration_test => stub(:method_name => @test_name)))
    @test_name = "test_user_pages"
  }

  it "strips leading hostname from link urls" do    
    crawler = Relevance::Tarantula::RailsIntegrationProxy.rails_integration_test(stub(:host => "foo.com"))
    crawler.transform_url("http://foo.com/path").should == "/path"
    crawler.transform_url("http://bar.com/path").should == "http://bar.com/path"
  end
  
  it "allows override of max_url_length" do
    crawler = Relevance::Tarantula::RailsIntegrationProxy.rails_integration_test(stub(:host => "foo.com"), 
                                             :max_url_length => 16)
    crawler.max_url_length.should == 16
  end

  it "has some useful defaults" do
    crawler = Relevance::Tarantula::RailsIntegrationProxy.rails_integration_test(stub(:host => "foo.com")) 
    crawler.log_grabber.should_not be_nil
  end
end


describe "Relevance::Tarantula::RailsIntegrationProxy" do
  %w{get post}.each do |http_method|
    it "can #{http_method}" do
      @rip = Relevance::Tarantula::RailsIntegrationProxy.new(stub)
      @response = stub({:code => :foo})
      @rip.integration_test = stub_everything(:response => @response)
      @rip.send(http_method, "/url").should == @response
    end
  end
  
  it "adds a response accessor to its delegate rails integration test" do
    o = Object.new
    Relevance::Tarantula::RailsIntegrationProxy.new(o)
    o.methods(false).sort.should == %w{response response=}
  end

end

describe "Relevance::Tarantula::RailsIntegrationProxy patching" do
  before do
    @rip = Relevance::Tarantula::RailsIntegrationProxy.new(stub)
    @rip.stubs(:rails_root).returns("faux_rails_root")
    @response = stub_everything({:code => "404", :headers => {}})
    File.stubs(:exist?).returns(true)
  end
  
  it "patches in Relevance::CoreExtensions::Response" do
    @rip = Relevance::Tarantula::RailsIntegrationProxy.new(stub)
    @rip.stubs(:rails_root).returns("faux_rails_root")
    @response = stub_everything({:code => "404", :headers => {}, :content_type => "text/html"})
    @response.meta.ancestors.should_not include(Relevance::CoreExtensions::Response)
    @rip.patch_response("/url", @response)
    @response.meta.ancestors.should include(Relevance::CoreExtensions::Response)
    @response.html?.should == true
  end
    
  it "replaces 404s with 200s, pulling content from public, for known text types" do
    File.expects(:extension).returns("html")
    @rip.expects(:static_content_file).with("/url").returns("File body")
    @rip.patch_response("/url", @response)
    @response.headers.should == {"type" => "text/html"}
  end
  
  it "logs and skips types we haven't dealt with yet" do
    File.expects(:extension).returns("whizzy")
    @rip.expects(:log).with("Skipping unknown type /url")
    @rip.patch_response("/url", @response)
  end
  
  it "can find static content relative to rails root" do
    @rip.static_content_path("foo").should == File.expand_path("faux_rails_root/public/foo")
  end
  
  it "can read static content relative to rails root" do
    File.expects(:read).with(@rip.static_content_path("foo"))
    @rip.static_content_file("foo")
  end
end
