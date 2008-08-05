module Relevance; end
module Relevance::IntegrationTestSupport
  include Relevance::ControllerTestSupport
  
  def url_for(*args)
    assert(@controller, "You must hit a controller first before calling url_for")
    super(*args)
  end
  
  def post_create_form
    assert_not_nil(form_model_name)
    post url_for_create, form_model_name=>object_for_create.attributes
  end
  
  def post_update_form
    assert_not_nil(form_model_name)
    post url_for_update, form_model_name=>object_for_edit.attributes
  end
  
  def post_destroy_form
    assert_not_nil(form_model_name)
    post url_for_destroy, :id=>object_for_edit.id
  end
end