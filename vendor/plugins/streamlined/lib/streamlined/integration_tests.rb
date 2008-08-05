# Creating a streamlined integration test
# 1. Starter File
# require "#{File.dirname(__FILE__)}/your_test_base"
# 
# class CampaignsIntegrationTest < YourTestBase
#   include Relevance::StreamlinedIntegrationTests
#   fixtures :campaigns
#   def setup
#     self.model_class = Campaign
#     self.form_fields = {:input=>[:name]}
#     post_valid_login
#   end
# end
#
# 2. YourTestBase should implement a valid login for your app, e.g.
# def post_valid_login
#   post '/account/login', {:user=>{:login=>:quentin, :password=>:test}}
#   assert_response :redirect
#   follow_redirect!
#   assert_response :success
#   assert_template 'homepage/home'
# end
#
# 3. Your fixtures should have a valid fixture named relevance_crud_fixture
#    If you use a different naming convention, inside setup you should
#    self.relevance_crud_fixture = :your_valid_fixture_name
#     
# 4. Specify form_fields in setup. You do not have to specify all fields. 
#    Those you do specify are checked with assert_select
# 
# 5. If your controller varies from normal streamlined behavior, override
#    test methods in streamlined_integration_tests.rb. Where feasible chain
#    back to super.
#
# 6. If your controller/action url convention varies from Rails' normal
#    override methods like url_for_destroy from integration_test_support.rb
#
# 7. If you need to tweak the fixture instance for a test, override methods
#    like object_for_create from integration_test_support.rb.

gem 'flexmock', '~> 0.6'
require 'relevance/integration_test_support'
module Streamlined; end
module Streamlined::IntegrationTests
  include Relevance::ControllerTestSupport
  include Relevance::IntegrationTestSupport
  def test_list
    get url_for_list
    assert_response :success
    assert_assigns(form_model_name.to_s.pluralize)
  end
  
  def test_new
    get url_for_new, params_for_new
    assert_response :success
    assert_true(assert_assigns(form_model_name).new_record?)
    assert_create_form
  end

  def test_successful_create
    model_validations_succeed_for(:new)
    assert_difference(model_class, :count) do
      post_create_form
      assert_valid(assert_assigns(form_model_name))
      assert_response(:redirect)
      assert_redirected_to :action=>"list"
    end
  end
  
  def test_failed_create
    model_validations_fail_for(:new)
    assert_no_difference(model_class, :count) do
      post_create_form
      assert_not_valid(assert_assigns(form_model_name))
      assert_template "new"
    end
  end

  def test_edit
    get url_for_edit
    assert_response :success
    assert_equal(object_for_edit, assigns(form_model_name))
    assert_update_form
  end

  def test_successful_update
    model_validations_succeed_for(:allocate)
    assert_no_difference(model_class, :count) do
      post_update_form
      assert_valid(assert_assigns(form_model_name))
      assert_response(:redirect)
      assert_redirected_to :action=>"list"
    end
  end

  def test_destroy
    assert_difference(model_class, :count, -1) do
      post_destroy_form
    end
  end
end