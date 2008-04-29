require File.join(File.dirname(__FILE__), "test_helper")

class IntegrationSessionTest < ActionController::IntegrationTest

  def setup
    @sess = open_session
    @sess.get "/test/rhtml", :content => <<-EOD
      <%= link_to "Index", { :action => "index" } %>
      <%= link_to 'Destroy', { :action => 'destroy'}, :method => :delete %>
      <%= form_tag(:action => 'create', :method => :post) %>
        <%= text_field_tag 'username', 'jason' %>
        <%= submit_tag %>
      </form>
    EOD
  end

  def test_select_form
    form = @sess.select_form
    assert_equal 'jason', form['username'].value
    form['username'] = 'brent'
    form.submit
    @sess.assert_response :success
    assert @sess.request.post?
    assert_equal 'brent', @sess.controller.params['username']
  end
  
  def test_select_link
    link = @sess.select_link 'Index'
    link.follow
    @sess.assert_response :success
    @sess.assert_action_name :index
  end

 def test_click_link_with_different_method
   link = @sess.select_link "/test/destroy"
   link.follow
   @sess.assert_response :success
   @sess.assert_action_name :destroy
 end
  
  def test_redirect_back_after_form_submit
    @sess.get "/test/rhtml", :content => <<-EOD
      <%= form_tag(:action => 'redirect_to_back') %>
        <%= submit_tag %>
      </form>
    EOD
    @sess.submit_form
    @sess.assert_redirected_to "/test/rhtml"
  end
  
  def test_select_methods_work_on_second_request_in_integration_test
    @sess.get "/test/rhtml", :content => <<-EOD
      <%= form_tag(:action => 'create') %>
      </form>
    EOD
    @sess.select_form "/test/create"
    
    @sess.get "/test/rhtml", :content => <<-EOD
      <%= form_tag(:action => 'destroy') %>
      </form>
    EOD
    @sess.select_form "/test/destroy"
    
    @sess.get "/test/rhtml", :content => <<-EOD
      <%= link_to "Index", { :action => "index" } %>
    EOD
    @sess.select_link("Index")
    
  end
end
