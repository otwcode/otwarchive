require File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb")

module HtmlReportHelperSpec
  # Is there an idiom for this?
  def self.included(base)
    base.before do
      @reporter = Object.new
      @reporter.extend Relevance::Tarantula::HtmlReportHelper
    end                                                                   
  end 
end

describe 'Relevance::Tarantula::HtmlReportHelper#wrap_in_line_number_table' do
  include HtmlReportHelperSpec
  it "can wrap text in a table row used for displaying lines and line numbers" do
    html = @reporter.wrap_in_line_number_table_row("Line 1\nLine 2")
    html.should == <<-END.strip
<tr><td class=\"numbers\"><span class=\"line number\">1</span><span class=\"line number\">2</span></td><td class=\"lines\"><span class=\"line\">Line 1</span><span class=\"line\">Line 2</span></td></tr>
END
  end  
end

describe 'Relevance::Tarantula::HtmlReportHelper#wrap_stack_trace_line' do
  include HtmlReportHelperSpec
  it "can wrap stack trace line in links" do                       
    line = %{/action_controller/filters.rb:697:in `call_filters'}
    @reporter.stubs(:textmate_url).returns("ide_url")
    html = @reporter.wrap_stack_trace_line(line)
    html.should == "<a href='ide_url'>/action_controller/filters.rb:697</a>:in `call_filters'"
  end  
  
  it "converts html entities for non-stack trace lines" do
    line = %{<a href="foo">escape me</a>}
    html = @reporter.wrap_stack_trace_line(line)
    html.should == %{&lt;a href=&quot;foo&quot;&gt;escape me&lt;/a&gt;}
  end

end

describe 'Relevance::Tarantula::HtmlReportHelper IDE help' do
  include HtmlReportHelperSpec
  it "can create a textmate url" do
    @reporter.stubs(:rails_root).returns("STUB_RAILS_ROOT")
    @reporter.textmate_url("/etc/somewhere", 100).should =~ %r{txmt://open\?url=.*/STUB_RAILS_ROOT/etc/somewhere&line_no=100}
  end
end
