require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/helpers/table_helper'

describe "Streamlined::TableHelper" do
  include Streamlined::Helpers::TableHelper
  attr_accessor :model_ui
  
  it "should render table filter when show_table_filter? returns true" do
    @model_ui.stubs(:show_table_filter?).returns(true)
    assert_select root_node(streamlined_filter), "div form" do
      assert_select "label[for=streamlined_filter_term]", "Filter:"
      assert_select "input[type=text][name=streamlined_filter_term][id=streamlined_filter_term]"
    end
  end
  
  it "should not render table filter when show_table_filter? returns false" do
    @model_ui.stubs(:show_table_filter?).returns(false)
    assert streamlined_filter.blank?
  end
end