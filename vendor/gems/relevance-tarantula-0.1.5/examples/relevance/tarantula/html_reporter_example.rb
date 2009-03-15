require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

describe "Relevance::Tarantula::HtmlReporter file output" do

  before do
    FileUtils.rm_rf(test_output_dir)
    FileUtils.mkdir_p(test_output_dir)
    @test_name = "test_user_pages"
    Relevance::Tarantula::Result.next_number = 0
    @success_results = (1..10).map do |index|
      Relevance::Tarantula::Result.new(
        :success => true, 
        :method => "get", 
        :url => "/widgets/#{index}", 
        :response => stub(:code => "200", :body => "<h1>header</h1>\n<p>text</p>"), 
        :referrer => "/random/#{rand(100)}", 
        :test_name => @test_name,
        :log => <<-END,
Made-up stack trace:
/some_module/some_class.rb:697:in `bad_method'
/some_module/other_class.rb:12345677:in `long_method'
this link should be <a href="#">escaped</a>
blah blah blah
        END
        :data => "{:param1 => :value, :param2 => :another_value}"
      )
    end
    @fail_results = (1..10).map do |index|
      Relevance::Tarantula::Result.new(
        :success => false, 
        :method => "get", 
        :url => "/widgets/#{index}", 
        :response => stub(:code => "500", :body => "<h1>header</h1>\n<p>text</p>"), 
        :referrer => "/random/#{rand(100)}", 
        :test_name => @test_name,
        :log => <<-END,
Made-up stack trace:
/some_module/some_class.rb:697:in `bad_method'
/some_module/other_class.rb:12345677:in `long_method'
this link should be <a href="#">escaped</a>
blah blah blah
        END
        :data => "{:param1 => :value, :param2 => :another_value}"
      )
    end
    @index = File.join(test_output_dir, "index.html")
    FileUtils.rm_f @index
    @detail = File.join(test_output_dir, @test_name,"1.html")
    FileUtils.rm_f @detail
  end
  
  it "creates a final report based on tarantula results" do
    Relevance::Tarantula::Result.any_instance.stubs(:rails_root).returns("STUB_ROOT")        
    reporter = Relevance::Tarantula::HtmlReporter.new(test_output_dir)
    stub_puts_and_print(reporter)
    (@success_results + @fail_results).each {|r| reporter.report(r)}
    reporter.finish_report(@test_name)
    File.exist?(@index).should be_true
  end 
  
  it "creates a final report with links to detailed reports in subdirs" do
    Relevance::Tarantula::Result.any_instance.stubs(:rails_root).returns("STUB_ROOT")
    reporter = Relevance::Tarantula::HtmlReporter.new(test_output_dir)
    stub_puts_and_print(reporter)
    (@success_results + @fail_results).each {|r| reporter.report(r)}
    reporter.finish_report(@test_name)
    links = Hpricot(File.read(@index)).search('.left a')
    links.each do |link|
      link['href'].should match(/#{@test_name}\/\d+\.html/)
    end
  end

  it "creates detailed reports based on tarantula results" do
    Relevance::Tarantula::Result.any_instance.stubs(:rails_root).returns("STUB_ROOT")        
    reporter = Relevance::Tarantula::HtmlReporter.new(test_output_dir)
    stub_puts_and_print(reporter)
    (@success_results + @fail_results).each {|r| reporter.report(r)}
    reporter.finish_report(@test_name)    
    File.exist?(@detail).should be_true
  end

end
