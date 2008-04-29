require File.join(File.dirname(__FILE__), "test_helper")

class SelectLinkTest < Test::Unit::TestCase
    
  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_select_link
    render_rhtml %Q{<%= link_to 'test' %>}
    assert_select "a", "test"
    link = select_link "test"
    assert_equal HTML::Tag, link.class
    
    assert_raise(Test::Unit::AssertionFailedError) do
      select_link 'foo'
    end
  end
  
  def test_select_link_when_enclosed
    render_rhtml %Q{<div><%= link_to 'test' %></div>}
    select_link "test"
  end
  
  def test_select_link_by_href
    render_rhtml %Q{<a href="/something/else"></a><%= link_to 'test', {:action => 'index'} %>}
    select_link '/test'
  end
  
  def test_select_link_by_contents
    render_rhtml %Q{<a>Create</a>  <%= link_to 'Destroy', {:action => 'destroy'} %>}
    select_link 'Destroy'
  end
  
  def test_selected_link_is_followable
    render_rhtml %Q{<%= link_to 'test', {:action => 'index'} %>}
    link = select_link 'test'
    link.follow
    assert_response :success
    assert_action_name :index
  end
    
  def test_selected_link_is_clickable
    render_rhtml %Q{<%= link_to 'test', {:action => 'index'} %>}
    link = select_link 'test'
    link.click
    assert_response :success
    assert_action_name :index
  end
  
  def test_selected_link_is_clickable_with_request_method
    render_rhtml %Q{<%= link_to "Destroy account", { :action => "destroy" }, :method => :delete %>}
    link = select_link "Destroy account"
    link.click
    assert_response :success
    assert_action_name :destroy
    assert_equal :delete, @request.method
  end
end
