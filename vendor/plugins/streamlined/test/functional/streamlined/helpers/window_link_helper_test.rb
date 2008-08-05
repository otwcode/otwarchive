require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))
require 'streamlined/helpers/window_link_helper'

require "#{RAILS_ROOT}/app/controllers/application"
class FoobarController < ApplicationController
end

describe "Streamlined::WindowLinkHelper" do
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper 

  include Streamlined::Helpers::WindowLinkHelper
  attr_accessor :model_ui, :model_name, :item
  
  fixtures :people, :phone_numbers
  
  # Stubbed to make Rails 2.x happy
  def protect_against_forgery?
    false
  end
  
  def setup 
    @controller = FoobarController.new
    request = ActionController::TestRequest.new
    response = ActionController::TestResponse.new
    request.relative_url_root = "/"
    request.path_parameters = {:action => 'new', :controller => 'foobar'}
    @controller.request = request
    @controller.instance_eval { @_params = {}} 
    @controller.send(:initialize_current_url)
  end
  
  it "guess show link for" do
    with_default_route do
      assert_equal "(multiple)", guess_show_link_for([])
      assert_equal "(unassigned)", guess_show_link_for(nil)
      assert_equal "(unknown)", guess_show_link_for(1)
      assert_equal "<a href=\"//people/show/1\">1</a>", guess_show_link_for(people(:justin))
      assert_equal "<a href=\"//phone_numbers/show/1\">1</a>", guess_show_link_for(phone_numbers(:number1))
    end
  end

  it "guess show link for model with to param override" do
    item = people(:justin)
    flexmock(item).stubs(:to_param).returns("some_seo_slug")
    with_default_route do
      assert_equal "<a href=\"//people/show/1\">1</a>", guess_show_link_for(item)
    end
  end
      
  it "link to new model" do
    @model_ui = flexmock(:read_only => false, :quick_new_button => true)
    @model_name = "Foo"
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.Windows.open_local_window_from_url" <<
                   "('New', '//foobar/new', null); return false;\"><img alt=\"New Foo\" border=\"0\" " <<
                   "src=\"//images/streamlined/add_16.png\" title=\"New Foo\" /></a>", link_to_new_model
    end
  end
  
  it "link to show model" do
    @model_ui = flexmock(:read_only => false, :quick_new_button => true)
    @model_name = "Foo"
    item = flexmock(:id => 123)
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.Windows.open_local_window_from_url" <<
                   "('Show', '//foobar/show/123', null); return false;\"><img alt=\"Show Foo\" border=\"0\" " <<
                   "src=\"//images/streamlined/search_16.png\" title=\"Show Foo\" /></a>", link_to_show_model(item)
    end
  end

  it "link to show model with to param override" do
    @model_ui = flexmock(:read_only => false)
    @model_name = "Foo"
    item = flexmock(:id => 123, :to_param => "some_seo_param")
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.Windows.open_local_window_from_url" <<
                    "('Show', '//foobar/show/123', null); return false;\"><img alt=\"Show Foo\" border=\"0\" "<<
                    "src=\"//images/streamlined/search_16.png\" title=\"Show Foo\" /></a>", link_to_show_model(item)
    end
  end
  
  it "link to edit model" do
    @model_ui = flexmock(:read_only => false, :quick_new_button => true)
    @model_name = "Foo"
    item = flexmock(:id => 123)
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.Windows.open_local_window_from_url" <<
                   "('Edit', '//foobar/edit/123', null); return false;\"><img alt=\"Edit Foo\" border=\"0\" " <<
                   "src=\"//images/streamlined/edit_16.png\" title=\"Edit Foo\" /></a>", link_to_edit_model(item)
    end
  end

  it "link to edit model with to param" do
    @model_ui = flexmock(:read_only => false, :quick_new_button => true)
    @model_name = "Foo"
    item = flexmock(:id => 123, :to_param => "some_seo_slug")
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.Windows.open_local_window_from_url" <<
                   "('Edit', '//foobar/edit/123', null); return false;\"><img alt=\"Edit Foo\" border=\"0\" " <<
                   "src=\"//images/streamlined/edit_16.png\" title=\"Edit Foo\" /></a>", link_to_edit_model(item)
    end
  end
  
  it "link to delete model" do
    item = flexmock(:id => 123)
    with_default_route do
      assert_equal "<a href=\"//foobar/destroy/123\" onclick=\"if (confirm('Are you sure?')) { " <<
                   "var f = document.createElement('form'); f.style.display = 'none'; " <<
                   "this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;" <<
                   "var m = document.createElement('input'); m.setAttribute('type', 'hidden'); " <<
                   "m.setAttribute('name', '_method'); m.setAttribute('value', 'post'); " <<
                   "f.appendChild(m);f.submit(); };return false;\"><img alt=\"Destroy\" " <<
                   "border=\"0\" src=\"//images/streamlined/delete_16.png\" " <<
                   "title=\"Destroy\" /></a>", link_to_delete_model(item)
    end
  end
  
  it "link to delete model" do
    item = flexmock(:id => 123, :to_param => "some_seo_slug")
    with_default_route do
      assert_equal "<a href=\"//foobar/destroy/123\" onclick=\"if (confirm('Are you sure?')) { " <<
                   "var f = document.createElement('form'); f.style.display = 'none'; " <<
                   "this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;" <<
                   "var m = document.createElement('input'); m.setAttribute('type', 'hidden'); " <<
                   "m.setAttribute('name', '_method'); m.setAttribute('value', 'post'); " <<
                   "f.appendChild(m);f.submit(); };return false;\"><img alt=\"Destroy\" " <<
                   "border=\"0\" src=\"//images/streamlined/delete_16.png\" " <<
                   "title=\"Destroy\" /></a>", link_to_delete_model(item)
    end
  end
  
  it "link to next page" do
    flexmock(self).should_receive(:page_link_style).and_return("").once
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.PageOptions.nextPage(); return false;\">" <<
                   "<img alt=\"Next Page\" border=\"0\" id=\"next_page\" " <<
                   "src=\"//images/streamlined/control-forward_16.png\" style=\"\" " <<
                   "title=\"Next Page\" /></a>", link_to_next_page
    end
  end
  
  it "link to previous page" do
    flexmock(self).should_receive(:page_link_style).and_return("").once
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.PageOptions.previousPage(); return false;\">" <<
                   "<img alt=\"Previous Page\" border=\"0\" id=\"previous_page\" " <<
                   "src=\"//images/streamlined/control-reverse_16.png\" style=\"\" " <<
                   "title=\"Previous Page\" /></a>", link_to_previous_page
    end
  end
  
  it "page link style without pages" do
    @streamlined_item_pages = []
    assert_equal "display: none;", page_link_style
  end
  
  it "page link style with previous page" do
    @streamlined_item_pages = flexmock(:empty? => false, :current => flexmock(:previous => true))
    assert_equal "", page_link_style
  end
  
  it "page link style without previous page" do
    @streamlined_item_pages = flexmock(:empty? => false, :current => flexmock(:previous => false))
    assert_equal "display: none;", page_link_style
  end
  
  it "link to new model when quick new button is false" do
    @model_ui = flexmock(:read_only => false, :quick_new_button => false)
    assert_nil link_to_new_model
  end
  
  it "wrap with link" do
    result = wrap_with_link("foo") { "bar" }
    assert_select root_node(result), "a[href=foo]", "bar"
  end
  
  it "wrap with link with empty block" do
    result = wrap_with_link("foo") {}
    assert_select root_node(result), "a[href=foo]", "foo"
  end
  
  it "wrap with link with array" do
    result = wrap_with_link(["foo", {:action => "bar"}]) { "bat" }
    assert_select root_node(result), "a[href=foo][action=bar]", "bat"
  end
  
  it "wrap with link with array and empty block" do
    result = wrap_with_link(["foo", {:action => "bar"}]) {}
    assert_select root_node(result), "a[href=foo][action=bar]", "foo"
  end
  
  private
  def with_default_route
    with_routing do |set|
      set.draw do |map|
        map.connect ':controller/:action/:id'
        yield
      end
    end
  end
end
