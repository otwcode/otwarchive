require File.expand_path(File.join(File.dirname(__FILE__), "../../../test_functional_helper"))
require "streamlined/helpers/breadcrumb_helper"

describe "Streamlined::BreadcrumbHelper" do
  fixtures :people

  def setup
    stock_controller_and_view
  end

  it "streamlined_breadcrumb defaults to false" do
    assert !@view.streamlined_breadcrumb
  end
  
  it "render streamlined_breadcrumb uses default trail" do
    assert_select root_node(@view.render_breadcrumb), "div[id=streamlined_breadcrumb]", "Home &lt; People"
  end

  it "render streamlined_breadcrumb for list context" do
    assert_render_breadcrumb(:list)
    assert_select root_node(@view.render_breadcrumb), "div[id=streamlined_breadcrumb]", "Home &lt; Fancy Models"
  end

  it "render streamlined_breadcrumb for edit context" do
    assert_render_breadcrumb_for_sub_context(:edit)
    flexmock(@view) do |m|
      m.should_receive(:prefix_for_crud_context).and_return("Edit").once
      m.should_receive(:header_text).with("Edit").and_return("Edit Some Name").once
    end
    assert_select root_node(@view.render_breadcrumb), "div[id=streamlined_breadcrumb]", "Home &lt; Fancy Models &lt; Edit Some Name" 
  end

  it "render streamlined_breadcrumb for new context" do
    assert_render_breadcrumb_for_sub_context(:new)
    flexmock(@view) do |m|
      m.should_receive(:prefix_for_crud_context).and_return("New").once
      m.should_receive(:header_text).with("New").and_return("New Some Name").once
    end
    assert_select root_node(@view.render_breadcrumb), "div[id=streamlined_breadcrumb]", "Home &lt; Fancy Models &lt; New Some Name" 
  end

  it "render streamlined_breadcrumb for other context" do
    assert_render_breadcrumb_for_sub_context(:foo)
    flexmock(@view) do |m| 
      m.should_receive(:prefix_for_crud_context).and_return(nil).once    
      m.should_receive(:header_text).with(nil).and_return("Foo").once
    end
    assert_select root_node(@view.render_breadcrumb), "div[id=streamlined_breadcrumb]", "Home &lt; Fancy Models &lt; Foo" 
  end
  
  private 
  def assert_render_breadcrumb(context)
    flexmock(@view) do |m|
      m.should_receive(:link_to).with("Home", "/").and_return("Home").once
      m.should_receive(:model_name => "FancyModel").once
      m.should_receive(:crud_context => context).at_least.once
    end
  end

  def assert_render_breadcrumb_for_sub_context(context)
    flexmock(@view).should_receive(:link_to).with("Fancy Models", {:action => "list"}).and_return("Fancy Models").once
    assert_render_breadcrumb(context)
  end
end