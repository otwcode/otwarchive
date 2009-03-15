require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe 'Relevance::Tarantula::Crawler#transform_url' do
  before {@crawler = Relevance::Tarantula::Crawler.new}
  it "de-obfuscates unicode obfuscated urls" do
    obfuscated_mailto = "&#109;&#97;&#105;&#108;&#116;&#111;&#58;"
    @crawler.transform_url(obfuscated_mailto).should == "mailto:"
  end
  
  it "strips the trailing name portion of a link" do
    @crawler.transform_url('http://host/path#name').should == 'http://host/path'
  end
end

describe 'Relevance::Tarantula::Crawler log grabbing' do
  it "returns nil if no grabber is specified" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.grab_log!.should == nil
  end
  
  it "returns grabber.grab if grabber is specified" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.log_grabber = stub(:grab! => "fake log entry")
    crawler.grab_log!.should == "fake log entry"
  end
end

describe 'Relevance::Tarantula::Crawler interruption' do
  it 'catches interruption and writes the partial report' do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.stubs(:queue_link)
    crawler.stubs(:do_crawl).raises(Interrupt)
    crawler.expects(:report_results)
    $stderr.expects(:puts).with("CTRL-C")
    crawler.crawl
  end
end

describe 'Relevance::Tarantula::Crawler handle_form_results' do
  it 'captures the result values (bugfix)' do
    response = stub_everything
    result_args = {:url => :action_stub, 
                    :data => 'nil', 
                    :response => response, 
                    :referrer => :action_stub, 
                    :log => nil, 
                    :method => :stub_method,
                    :test_name => nil}
    result = Relevance::Tarantula::Result.new(result_args)
    Relevance::Tarantula::Result.expects(:new).with(result_args).returns(result)
    crawler = Relevance::Tarantula::Crawler.new
    crawler.handle_form_results(stub_everything(:method => :stub_method, :action => :action_stub), 
                                response)
  end
end

describe 'Relevance::Tarantula::Crawler#crawl' do
  it 'queues the first url, does crawl, and then reports results' do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.expects(:queue_link).with("/foobar")
    crawler.expects(:do_crawl)
    crawler.expects(:report_results)
    crawler.crawl("/foobar")
  end
  
  it 'reports results even if the crawl fails' do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.expects(:do_crawl).raises(RuntimeError)
    crawler.expects(:report_results)
    lambda {crawler.crawl('/')}.should raise_error(RuntimeError)
  end
end

describe 'Relevance::Tarantula::Crawler queuing' do
  it 'queues and remembers links' do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.expects(:transform_url).with("/url").returns("/transformed")
    crawler.queue_link("/url")
    crawler.links_to_crawl.should == [Relevance::Tarantula::Link.new("/transformed")]
    crawler.links_queued.should == Set.new([Relevance::Tarantula::Link.new("/transformed")])
  end
  
  it 'queues and remembers forms' do
    crawler = Relevance::Tarantula::Crawler.new
    form = Hpricot('<form action="/action" method="post"/>').at('form')
    signature = Relevance::Tarantula::FormSubmission.new(Relevance::Tarantula::Form.new(form)).signature
    crawler.queue_form(form)
    crawler.forms_to_crawl.size.should == 1
    crawler.form_signatures_queued.should == Set.new([signature])
  end
  
  it 'remembers link referrer if there is one' do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.queue_link("/url", "/some-referrer")
    crawler.referrers.should == {Relevance::Tarantula::Link.new("/url") => "/some-referrer"}
  end
  
end

describe 'Relevance::Tarantula::Crawler#report_results' do
  it "delegates to generate_reports" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.expects(:generate_reports)
    crawler.report_results
  end
end

describe 'Relevance::Tarantula::Crawler#crawling' do

  it "converts ActiveRecord::RecordNotFound into a 404" do
    (proxy = stub_everything).expects(:send).raises(ActiveRecord::RecordNotFound)
    crawler = Relevance::Tarantula::Crawler.new
    crawler.proxy = proxy
    response = crawler.crawl_form stub_everything(:method => nil)
    response.code.should == "404"
    response.content_type.should == "text/plain"
    response.body.should == "ActiveRecord::RecordNotFound"
  end

  it "does four things with each link: get, log, handle, and blip" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.proxy = stub
    response = stub(:code => "200")
    crawler.links_to_crawl = [stub(:href => "/foo1", :method => :get), stub(:href => "/foo2", :method => :get)]
    crawler.proxy.expects(:get).returns(response).times(2)
    crawler.expects(:log).times(2)
    crawler.expects(:handle_link_results).times(2)
    crawler.expects(:blip).times(2)
    crawler.crawl_queued_links
    crawler.links_to_crawl.should == []
  end
    
  it "invokes queued forms, logs responses, and calls handlers" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.forms_to_crawl << stub_everything(:method => "get", 
                                              :action => "/foo",
                                              :data => "some data",
                                              :to_s => "stub")
    crawler.proxy = stub_everything(:send => stub(:code => "200" ))
    crawler.expects(:log).with("Response 200 for stub")
    crawler.expects(:blip)
    crawler.crawl_queued_forms
  end
  
  it "resets to the initial links/forms on subsequent crawls when times_to_crawl > 1" do
    crawler = Relevance::Tarantula::Crawler.new
    stub_puts_and_print(crawler)
    crawler.proxy = stub
    response = stub(:code => "200")
    crawler.links_to_crawl = [stub(:href => "/foo", :method => :get)]
    crawler.proxy.expects(:get).returns(response).times(4) # (stub and "/") * 2
    crawler.forms_to_crawl << stub_everything(:method => "post", 
                                              :action => "/foo",
                                              :data => "some data",
                                              :to_s => "stub")
    crawler.proxy.expects(:post).returns(response).times(2)
    crawler.expects(:links_completed_count).returns(*(0..6).to_a).times(6)
    crawler.times_to_crawl = 2
    crawler.crawl
  end
end

describe 'Crawler blip' do
  it "blips the current progress if !verbose" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.stubs(:verbose).returns false
    crawler.expects(:print).with("\r 0 of 0 links completed               ")
    crawler.blip
  end
  it "blips nothing if verbose" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.stubs(:verbose).returns true
    crawler.expects(:print).never
    crawler.blip
  end
end

describe 'Relevance::Tarantula::Crawler' do
  it "is finished when the links and forms are crawled" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.finished?.should == true
  end

  it "isn't finished when links remain" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.links_to_crawl = [:stub_link]
    crawler.finished?.should == false
  end

  it "isn't finished when links remain" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.forms_to_crawl = [:stub_form]
    crawler.finished?.should == false
  end
  
  it "crawls links and forms again and again until finished?==true" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.expects(:finished?).times(3).returns(false, false, true)
    crawler.expects(:crawl_queued_links).times(2)
    crawler.expects(:crawl_queued_forms).times(2)
    crawler.do_crawl
  end
  
  it "asks each reporter to write its report in report_dir" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.stubs(:report_dir).returns(test_output_dir)
    reporter = stub_everything
    reporter.expects(:report)
    reporter.expects(:finish_report)
    crawler.reporters = [reporter]
    crawler.save_result stub(:code => "404", :url => "/uh-oh")
    crawler.generate_reports
  end
  
  it "builds a report dir relative to rails root" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.expects(:rails_root).returns("faux_rails_root")
    crawler.report_dir.should == "faux_rails_root/tmp/tarantula"
  end
  
  it "skips links that are already queued" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.should_skip_link?(Relevance::Tarantula::Link.new("/foo")).should == false
    crawler.queue_link("/foo").should == Relevance::Tarantula::Link.new("/foo")
    crawler.should_skip_link?(Relevance::Tarantula::Link.new("/foo")).should == true
  end
  
end
                         
describe "Crawler link skipping" do   
  before do
    @crawler = Relevance::Tarantula::Crawler.new
  end
  
  it "skips links that are too long" do
    @crawler.should_skip_link?(Relevance::Tarantula::Link.new("/foo")).should == false
    @crawler.max_url_length = 2
    @crawler.expects(:log).with("Skipping long url /foo")
    @crawler.should_skip_link?(Relevance::Tarantula::Link.new("/foo")).should == true
  end
  
  it "skips outbound links (those that begin with http)" do
    @crawler.expects(:log).with("Skipping http-anything")
    @crawler.should_skip_link?(Relevance::Tarantula::Link.new("http-anything")).should == true
  end

  it "skips javascript links (those that begin with javascript)" do
    @crawler.expects(:log).with("Skipping javascript-anything")
    @crawler.should_skip_link?(Relevance::Tarantula::Link.new("javascript-anything")).should == true
  end

  it "skips mailto links (those that begin with http)" do
    @crawler.expects(:log).with("Skipping mailto-anything")
    @crawler.should_skip_link?(Relevance::Tarantula::Link.new("mailto-anything")).should == true
  end
  
  it 'skips blank links' do
    @crawler.queue_link(nil)
    @crawler.links_to_crawl.should == []
    @crawler.queue_link("")
    @crawler.links_to_crawl.should == []
  end
  
  it "logs and skips links that match a pattern" do
    @crawler.expects(:log).with("Skipping /the-red-button")
    @crawler.skip_uri_patterns << /red-button/
    @crawler.queue_link("/blue-button").should == Relevance::Tarantula::Link.new("/blue-button")
    @crawler.queue_link("/the-red-button").should == nil
  end   
  
  it "logs and skips form submissions that match a pattern" do
    @crawler.expects(:log).with("Skipping /reset-password-form")
    @crawler.skip_uri_patterns << /reset-password/             
    fs = stub_everything(:action => "/reset-password-form")
    @crawler.should_skip_form_submission?(fs).should == true
  end
end

describe "allow_nnn_for" do
  it "installs result as a response_code_handler" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.response_code_handler.should == Relevance::Tarantula::Result
  end
  
  it "delegates to the response_code_handler" do
    crawler = Relevance::Tarantula::Crawler.new
    (response_code_handler = mock).expects(:allow_404_for).with(:stub)
    crawler.response_code_handler = response_code_handler
    crawler.allow_404_for(:stub)
  end
  
  it "chains up to super for method_missing" do
    crawler = Relevance::Tarantula::Crawler.new
    lambda{crawler.foo}.should raise_error(NoMethodError)
  end
end
