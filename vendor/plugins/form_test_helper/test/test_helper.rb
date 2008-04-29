unless defined?(RAILS_ROOT)
 RAILS_ROOT = ENV["RAILS_ROOT"] || File.expand_path(File.join(File.dirname(__FILE__), "../../../.."))
end

require File.join(RAILS_ROOT, "test", "test_helper")
require File.join(File.dirname(__FILE__), "..", "init")

CONTROLLER_FIXTURE_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 'fixtures/controllers')
require File.join(CONTROLLER_FIXTURE_DIR, 'other_controller')
require File.join(CONTROLLER_FIXTURE_DIR, 'test_controller')
require File.join(CONTROLLER_FIXTURE_DIR, 'admin/namespaced_controller')

# Rails Trunk Revision 7421 changed how routes are processed in integration tests.
# Now we have to specify controllers in files and ensure that we have supplied the
# correct controller_paths for them.
ActionController::Routing::Routes.clear!
ActionController::Routing.controller_paths= [ CONTROLLER_FIXTURE_DIR ]
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }

# load the controllers
ActionController::Routing.controller_paths.each do |path|
  Dir["#{path}/*.rb"].each { |f| require f }
end

# Rails Trunk is reloading routes on every request. We want to use
# our custom routes so we're overriding the methods which do the dirty work
class ActionController::Routing::RouteSet
  def reload ; end
  def load! ; end
  def reload! ; end
  def load ; end
end

module FormTestHelperAssertions

  def render_rhtml(rhtml)
    @controller.response_with = rhtml
    get :rhtml
  end

  def render_html(html)
    @controller.response_with = html
    get :html
  end

  def render_rjs(&block)
    @controller.response_with &block
    get :rjs
  end

  def render_xml(xml)
    @controller.response_with = xml
    get :xml
  end
  
  def assert_action_name(expected_name)
    assert_equal expected_name.to_s, @controller.action_name, "Didn't follow link"
  end
  
end

module XHRHelpers
  def render_for_xhr
    render_rhtml <<-EOD
      <% form_remote_tag :url => {:action => 'create'}, :html => { :action => "/test/edit" }  do -%>
        <%= text_field_tag "username", "jason" %>
        <%= submit_tag %>
      <% end -%>
    EOD
  end
  
  def check_xhr_responses(new_value)
    assert_response :success
    assert_match 'xhr', @response.body
    assert_equal new_value, @controller.params[:username]
  end
end

Test::Unit::TestCase.send :include, FormTestHelperAssertions
ActionController::Integration::Session.send :include, FormTestHelperAssertions