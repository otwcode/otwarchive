require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/controller/options_methods'

describe "Streamlined::Controller::OptionsMethods" do
  include Streamlined::Controller::OptionsMethods
  
  it "merge count or find options" do
    mock_count_or_find_options(:conditions => "foo=1")
    merge_count_or_find_options(options = {})
    assert_equal({ :conditions => "foo=1" }, options)
  end
  
  it "count or find options with empty hash" do
    mock_count_or_find_options({})
    assert_equal({}, count_or_find_options)
  end
  
  it "count or find options with strings" do
    mock_count_or_find_options(:conditions => "foo=1")
    assert_equal({:conditions => "foo=1"}, count_or_find_options)
  end
  
  it "count or find options with method symbols" do
    mock_count_or_find_options(:conditions => :foo_method)
    flexmock(self).should_receive(:foo_method => "foo=1").once
    assert_equal({:conditions => "foo=1"}, count_or_find_options)
  end
  
  private
  def mock_count_or_find_options(options)
    flexmock(self.class).should_receive(:count_or_find_options => options).once
  end
end