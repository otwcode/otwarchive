require 'test/unit'
require 'rubygems'
require 'active_record'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view'
require File.dirname(__FILE__) + '/../lib/live_validations'
require File.dirname(__FILE__) + '/../lib/form_helpers'
require File.dirname(__FILE__) + '/../test/resource'

class ResourcesController < ActionController::Base
  def without_instance_var
    render_form(:text, :name)
  end

  def without_live
    @resource = Resource.new
    render :inline => "<% form_for(:resource, :url => resources_path) do |f| %><%= f.text_field :name, :live => false %><% end %>" 
  end
  
  def with_live
    @resource = Resource.new
    render :inline => "<% form_for(:resource, :url => resources_path) do |f| %><%= f.text_field :name, :live => true %><% end %>" 
  end

  def with_string
    @resource = Resource.new
    render :inline => "<% form_for(:resource, :url => resources_path) do |f| %><%= f.text_field 'name' %><% end %>"    
  end
  
  def with_text_area
    @resource = Resource.new
    render :inline => "<% form_for(:resource, :url => resources_path) do |f| %><%= f.text_area :name %><% end %>"    
  end

  def name
    @resource = Resource.new
    render_form(:text, :name)
  end
  
  def amount
    @resource = Resource.new
    render_form(:text, :amount)
  end
  
  def password
    @resource = Resource.new
    render :inline => "<% form_for(:resource, :url => resources_path) do |f| %><%= f.password_field :password %><%= f.password_field :password_confirmation %><% end %>"    
  end

  def rescue_action(e)
    raise e
  end
  
  private
  
  def render_form(type, method)
    render :inline => "<% form_for(:resource, :url => resources_path) do |f| %><%= f.#{type}_field :#{method} %><% end %>"    
  end
end

ActionController::Routing::Routes.draw do |map|
  map.resources :resources
  map.connect ':controller/:action/:id'
end

class FormHelpersTest < Test::Unit::TestCase
  
  def setup
    @controller = ResourcesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Resource.class_eval do # reset live validations
      @live_validations = {}
    end
    ActionView::live_validations = true # reset default behaviour
  end

  def test_without_instance_var
    get :without_instance_var
    check_form_item :type => 'text', :name => 'name'
  end

  def test_without_live
    Resource.class_eval do
      validates_presence_of :name
    end
    get :without_live
    check_form_item :type => 'text', :name => 'name'
  end

  def test_without_live_with_false_default
    ActionView::live_validations = false
    Resource.class_eval do
      validates_presence_of :name
    end
    get :name
    check_form_item :type => 'text', :name => 'name'
  end
  
  def test_with_live_with_false_default
    ActionView::live_validations = false
    Resource.class_eval do
      validates_presence_of :name
    end
    get :with_live
    check_form_item :type => 'text', :name => 'name' do |script|
      assert_matches script, "var resource_name = new LiveValidation('resource_name');resource_name.add(Validate.Presence, {\"validMessage\": \"\"})"
    end
  end
  
  def test_with_string
    Resource.class_eval do
      validates_presence_of :name
    end
    get :with_string
    check_form_item :type => 'text', :name => 'name' do |script|
      assert_matches script, "var resource_name = new LiveValidation('resource_name');resource_name.add(Validate.Presence, {\"validMessage\": \"\"})"
    end
  end
  
  def test_with_text_area
    Resource.class_eval do
      validates_presence_of :name
    end
    get :with_text_area
    assert_response :ok
    assert_select 'form[action="/resources"]' do
      assert_select "textarea[id='resource_name']"
      assert_select 'script', "var resource_name = new LiveValidation('resource_name');resource_name.add(Validate.Presence, {\"validMessage\": \"\"})"
    end
  end

  def test_presence
    Resource.class_eval do
      validates_presence_of :name
    end
    get :name
    check_form_item :type => 'text', :name => 'name' do |script|
      assert_matches script, "var resource_name = new LiveValidation('resource_name');resource_name.add(Validate.Presence, {\"validMessage\": \"\"})"
    end
  end

  def test_presence_with_message
    Resource.class_eval do
      validates_presence_of :name, :message => 'is required'
    end
    get :name
    check_form_item :type => 'text', :name => 'name' do |script|
      assert_matches script, /var resource_name = new LiveValidation\('resource_name'\);resource_name.add\(Validate.Presence, \{(.+)\}\)/
      assert_matches script, "\"validMessage\": \"\""
      assert_matches script, "\"failureMessage\": \"is required\""
    end
  end

  def test_numericality
    Resource.class_eval do
      validates_numericality_of :amount
    end
    get :amount
    check_form_item :type => 'text', :name => 'amount' do |script|
      assert_matches script, "var resource_amount = new LiveValidation('resource_amount');resource_amount.add(Validate.Numericality, {\"validMessage\": \"\"})"
    end
  end

  def test_numericality_only_integer
    Resource.class_eval do
      validates_numericality_of :amount, :only_integer => true
    end
    get :amount
    check_form_item :type => 'text', :name => 'amount' do |script|
      assert_matches script, /var resource_amount = new LiveValidation\('resource_amount'\);resource_amount.add\(Validate.Numericality, \{(.*)\}\)/
      assert_matches script, "\"onlyInteger\": true"
      assert_matches script, "\"validMessage\": \"\""
    end
  end
  
  def test_confirmation
    Resource.class_eval do
      validates_confirmation_of :password
    end
    get :password
    check_form_item :type => 'password', :name => 'password' do |script|
      assert_matches script, /var resource_password = new LiveValidation\('resource_password'\);resource_password.add\(Validate.Confirmation, \{(.*)\}\)/
      assert_matches script, "\"match\": \"resource_password_confirmation\""
      assert_matches script, "\"validMessage\": \"\""
    end
  end
  
  private

  def check_form_item(options = {}, &blk)
    assert_response :ok
    assert_select 'form[action="/resources"]' do
      assert_select "input[type='#{options[:type]}'][id='resource_#{options[:name]}']"
      if block_given?
        assert_select 'script' do |element|
          yield(element.to_s)
        end
      else
        assert_select 'script', 0
      end
    end
  end
  
  def assert_matches(string, regexp)
    if regexp.is_a?(Regexp)
      assert string =~ regexp, "#{string} doesn't match #{regexp}"
    else
      assert string[regexp], "#{string} doesn't match #{regexp}"
    end
  end

end
