require File.join(File.dirname(__FILE__), "test_helper")

class IntegrationTest < ActionController::IntegrationTest

  def setup
    get "/test/rhtml", :content => <<-EOD
      <%= link_to "Index", { :action => "index" } %>
      <%= link_to 'Destroy', { :action => 'destroy'}, :method => :delete %>
      <%= form_tag(:action => 'create', :method => :post) %>
        <%= text_field_tag 'username', 'jason' %>
        <%= submit_tag %>
      </form>
    EOD
  end

  def test_select_form
    form = select_form
    assert_equal 'jason', form['username'].value
    form['username'] = 'brent'
    form.submit
    assert_response :success
    assert request.post?
    assert_equal 'brent', controller.params['username']
  end
  
  def test_select_link
    link = select_link 'Index'
    link.follow
    assert_response :success
    assert_action_name :index
  end

 def test_click_link_with_different_method
   link = select_link "/test/destroy"
   link.follow
   assert_response :success
   assert_action_name :destroy
 end
  
  def test_redirect_back_after_form_submit
    get "/test/rhtml", :content => <<-EOD
      <%= form_tag(:action => 'redirect_to_back') %>
        <%= submit_tag %>
      </form>
    EOD
    submit_form
    assert_redirected_to "/test/rhtml"
  end
  
  def test_select_methods_work_on_second_request_in_integration_test
    get "/test/rhtml", :content => <<-EOD
      <%= form_tag(:action => 'create') %>
      </form>
    EOD
    select_form "/test/create"
    
    get "/test/rhtml", :content => <<-EOD
      <%= form_tag(:action => 'destroy') %>
      </form>
    EOD
    select_form "/test/destroy"
    
    get "/test/rhtml", :content => <<-EOD
      <%= link_to "Index", { :action => "index" } %>
    EOD
    select_link("Index")
    
  end
end
