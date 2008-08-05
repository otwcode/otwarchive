require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/view/render_methods'

describe "Streamlined::View::RenderMethods" do
  def render(*args)
    nil
  end
  
  include Streamlined::View::RenderMethods
  
  it "controller name" do
    flexmock(self).should_receive(:controller => flexmock(:controller_name => "foo")).once
    assert_equal "foo", controller_name
  end
  
  it "convert partial options for generic" do
    setup_mocks(false)
    options = {:partial=>"list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:layout=>false, :file=>generic_view("_list"), :other=>"1", :use_full_path => false}, options)
  end

  it "convert partial options and layout for generic" do
    setup_mocks(false)
    options = {:partial=>"list", :other=>"1", :layout=>true}
    convert_partial_options(options)
    assert_equal({:layout=>true, :file=>generic_view("_list"), :other=>"1", :use_full_path => false}, options)
  end

  it "convert partial options for specific" do
    setup_mocks(true)
    options = {:partial=>"list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:partial=>"list", :other=>"1"}, options)
  end
  
  private
  def setup_mocks(template_exists)
    flexstub(self) do |s|
      s.should_receive(:specific_template_exists?).and_return(template_exists)
      s.should_receive(:controller_path).and_return("people")
      s.should_receive(:managed_partials_include?).and_return(true)
    end
  end
end