gem 'flexmock', '~> 0.6'
require 'relevance/controller_test_support'
module Streamlined; end
module Streamlined::FunctionalTests
  include Relevance::ControllerTestSupport
  def url_for(*args)
    assert(@controller, "You must hit a controller first before calling url_for")
    @controller.url_for(*args)
  end
  def post_create_form
    assert_not_nil(form_model_name)
    post :create, form_model_name => object_for_create.attributes
  end

  def post_update_form(ajax = nil)
    assert_not_nil(form_model_name)
    object_attributes = object_for_edit.attributes
    object_attributes.delete('id')
    args = [:update, {:id=>object_for_edit.id, form_model_name=>object_attributes}]
    if ajax == :xhr
      xhr :post, *args
    else
      post *args
    end
  end

  def post_destroy_form
    assert_not_nil(form_model_name)
    post :destroy, :id=>object_for_edit.id
  end
  
  # have to allow for both path-to-name and name
  def assert_streamlined_template(expected, message=nil)
    rendered = File.basename(@response.rendered_file,".*")
    msg = build_message(message, "expecting <?> but rendering with <?>", expected, rendered)
    assert_equal expected, rendered, msg
  end
  
  def test_list
    get :list
    assert_response :success
    assert_assigns(form_model_name.to_s.pluralize)
    assert_streamlined_template("list")
  end

  def test_new
    get :new, params_for_new
    assert_response :success
    assert_true(assert_assigns(form_model_name).new_record?)
    assert_create_form
    assert_not_nil assigns(:streamlined_item)
    assert_unobtrusive_javascript
    assert_streamlined_template("new")
  end

  def test_successful_create
    model_validations_succeed_for(:new)
    assert_difference(model_class, :count) do
      post_create_form
      assert_valid(assert_assigns(form_model_name))
      assert_success_or_redirect
    end
  end
  
  def test_failed_create
    model_validations_fail_for(:new)
    assert_no_difference(model_class, :count) do
      post_create_form
      assert_not_valid(assert_assigns(form_model_name))
      assert_response :success
      assert_streamlined_template("new")
    end
  end

  def test_edit
    get :edit, :id => object_for_edit
    assert_response :success
    assert_equal(object_for_edit, assigns(form_model_name))
    assert_update_form
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
    assert_streamlined_template("edit")
    assert_unobtrusive_javascript
  end
  
  def test_successful_update
    model_validations_succeed_for(:allocate)
    assert_no_difference(model_class, :count) do
      post_update_form
      assert_valid(assert_assigns(form_model_name))
      assert_response :redirect
      assert_redirected_to :action=>"list"
    end
  end

  def test_successful_update_xhr
    model_validations_succeed_for(:allocate)
    assert_no_difference(model_class, :count) do
      post_update_form(:xhr)
      assert_valid(assert_assigns(form_model_name))
      assert_response :success
      assert_streamlined_template("show")
    end
  end

  def test_failed_update
    model_validations_fail_for(:allocate)
    assert_no_difference(model_class, :count) do
      post_update_form
      assert_not_valid(assigns(form_model_name))
      assert_response :success
      assert_streamlined_template("edit")
    end
  end


  def test_destroy
    assert_difference(model_class, :count, -1) do
      post_destroy_form
      assert_response :redirect
      assert_redirected_to :action => 'list'
    end
  end
  
end