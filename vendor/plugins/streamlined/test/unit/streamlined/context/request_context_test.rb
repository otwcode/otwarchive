require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))

include Streamlined::Context
describe "Streamlined::Context::RequestContext" do
  it "ascending" do
    o = RequestContext.new(:sort_order=>'ASC', :sort_column=>"name")
    assert o.sort_ascending?
    assert_equal({:order=>"name ASC"}, o.active_record_order_option)
  end
  
  it "default ordering" do
    o = RequestContext.new(:sort_column=>"name")
    assert o.sort_ascending?
    assert_equal({:order=>"name ASC"}, o.active_record_order_option)
  end
  
  it "descending" do
    o = RequestContext.new(:sort_order=>'DESC', :sort_column=>"name")
    assert !o.sort_ascending?
    assert_equal({:order=>"name DESC"}, o.active_record_order_option)
  end
  
  it "empty order option" do
    o = RequestContext.new
    assert_equal({}, o.active_record_order_option)
  end
  
  it "sort column" do
    o = RequestContext.new
    column = Struct.new(:name).new("foo")
    assert_equal false, o.sort_column?(column)
    o.sort_column = "foo"
    assert_equal true, o.sort_column?(column)
  end
end