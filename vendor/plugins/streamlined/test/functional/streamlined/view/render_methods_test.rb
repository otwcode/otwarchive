require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))
require 'streamlined/helpers/link_helper'

describe "Streamlined::View::RenderMethods" do
  def setup
    stock_controller_and_view
  end
  
  it "convert partial options for managed partial" do
    assert_true @view.send(:managed_partials_include?, "list")
    assert_equal({
      :file => File.join(STREAMLINED_GENERIC_VIEW_ROOT, "_list.rhtml"), 
      :layout => false,
      :use_full_path => false
    }, @view.convert_partial_options(:partial => "list"))
  end

  it "convert partial options leaves non managed partial alone" do
    assert_false @view.send(:managed_partials_include?, "foo")
    assert_equal({:partial=>"foo"}, @view.convert_partial_options(:partial => "foo"))
  end
  
  
end