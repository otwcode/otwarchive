require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))
require 'streamlined/breadcrumb'

describe "Streamlined::Breadcrumb" do
  include Streamlined::Breadcrumb
  
  it "node for list crud context" do
    flexmock(self).should_receive(:link_to).with("Flex Mocks", :controller => "flex_mocks", :action => "list")
    instance = flexmock(:id => 123, :name => "foo")
    node_for(:list, instance).call
  end
  
  it "node for show crud context" do
    flexmock(self).should_receive(:link_to).with("foo", :controller => "flex_mocks", :action => "show", :id => 123)
    instance = flexmock(:id => 123, :name => "foo")
    node_for(:show, instance).call
  end
  
  it "node for bogus crud context" do
    assert_nil node_for(:bogus, flexmock)
  end
end