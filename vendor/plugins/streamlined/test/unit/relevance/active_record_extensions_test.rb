require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))
require 'relevance/active_record_extensions'

describe "ActiveRecordExtensions" do
  
  def setup
    @inst = Object.new
    @cls = Object.new
    @inst.extend(Relevance::ActiveRecordExtensions::InstanceMethods)
    @cls.extend(Relevance::ActiveRecordExtensions::ClassMethods)
  end
  
  it "streamlined name returns id" do
    flexstub(@inst).should_receive(:id).and_return(123)
    assert_equal(123, @inst.streamlined_name)
  end
  
  it "streamlined name returns title" do
    @inst.instance_eval { def title; "title"; end }
    assert_equal("title", @inst.streamlined_name)
  end
  
  it "streamlined name returns name" do
    @inst.instance_eval { def name; "name"; end }
    assert_equal("name", @inst.streamlined_name)
  end
  
  it "streamlined name returns options" do
    flexstub(@inst).should_receive(:id).and_return(123)
    @inst.instance_eval { def title; "title"; end }
    assert_equal("title:123", @inst.streamlined_name([:title,:id]))
  end
  
  it "streamlined name returns options with delimiter" do
    flexstub(@inst).should_receive(:id).and_return(123)
    @inst.instance_eval { def title; "title"; end }
    assert_equal("title-123", @inst.streamlined_name([:title,:id], "-"))
  end
  
  it "streamlined name with instance that has name method with single arg" do
    flexstub(@inst).should_receive(:id).and_return(123)
    @inst.instance_eval { def name(arg); end }
    @inst.streamlined_name.should == 123
  end
  
  it "streamlined name with instance that has title method with single arg" do
    flexstub(@inst).should_receive(:id).and_return(123)
    @inst.instance_eval { def title(arg); end }
    @inst.streamlined_name.should == 123
  end
  
  it "user columns" do
    s = Struct.new(:name)
    flexstub(@cls).should_receive(:content_columns).and_return do
      %w{_at _on position alpha lock_version _id password_hash beta}.map{|name| s.new(name)}
    end
    assert_equal %w{alpha beta}, @cls.user_columns.map(&:name)
  end
  
  it "returns streamlined css id" do
    @inst.stubs(:id).returns(123)
    @inst.streamlined_css_id.should == "object_123"
  end
  
end
