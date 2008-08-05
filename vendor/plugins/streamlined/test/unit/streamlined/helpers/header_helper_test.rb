require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/helpers/header_helper'

describe "HeaderHelper" do
  
  class FancyController
    include Streamlined::Helpers::HeaderHelper
    attr_accessor :instance, :model_name, :crud_context
  end
  
  def setup
    @controller = FancyController.new
    @controller.model_name = "Fancy Model"
  end
  
  it "render header" do
    assert_header_text "Very Fancy Model", @controller.render_header("Very")
  end
  
  it "render full header" do
    assert_header_text "Some Text", @controller.render_full_header("Some Text")
  end
  
  it "render show header" do
    flexmock(@controller).should_receive(:crud_context => :show)
    assert_header_text "Fancy Model", @controller.render_show_header
  end
  
  it "render edit header" do
    assert_header_text "Edit Fancy Model", @controller.render_edit_header
  end

  it "render new header" do
    assert_header_text "New Fancy Model", @controller.render_new_header
  end
  
  it "prefix for crud context edit" do
    @controller.crud_context = :edit
    assert_equal "Edit", @controller.prefix_for_crud_context
  end
  
  it "prefix for crud context new" do
    @controller.crud_context = :new
    assert_equal "New", @controller.prefix_for_crud_context
  end
  
  it "prefix for crud context with bogus context" do
    @controller.crud_context = :bogus
    assert_nil @controller.prefix_for_crud_context
  end
  
  it "header text with name" do
    class SomeInstance; def name; "Some Instance"; end; end
    @controller.instance = SomeInstance.new
    @controller.header_text.should == "Some Instance"
  end
  
  it "header text with name that has one arg" do
    class SomeInstance; def name(arg); end; end
    @controller.instance = SomeInstance.new
    @controller.header_text.should == "Fancy Model"
  end

  private
  def assert_header_text(expected_header_text, actual_header_html)
    root = HTML::Document.new(actual_header_html).root
    assert_select root, "div[class=streamlined_header]" do
      assert_select "h2", expected_header_text
    end
  end  
end
