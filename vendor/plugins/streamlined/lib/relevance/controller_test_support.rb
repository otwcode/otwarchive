module Relevance; end
module Relevance::ControllerTestSupport
  include FlexMock::TestCase
  include Relevance::RailsAssertions
  
  # Many attributes will derive by inference from :model_class if you do not set them
  attr_accessor :model_class, :controller_name
  attr_writer :object_for_create, :url_base, :object_for_new, :object_for_edit, :form_model_name, :form_fields
  attr_with_default :relevance_crud_fixture, ":relevance_crud_fixture"
  attr_with_default :params_for_new, "{}"
  
  def url_base
    unless @url_base
      assert_not_nil(form_model_name)
      @url_base = {:controller=>form_model_name.to_s.pluralize, :only_path=>true}
    end
    @url_base
  end

  def form_fields
    assert(@form_fields, "@form_fields is required")
    @form_fields
  end

  def object_for_new
    unless @object_for_new
      assert_not_nil(@model_class)
      @object_for_new = @model_class.new
    end
    @object_for_new
  end

  def form_model_name
    unless @form_model_name
      assert_not_nil(@model_class, "@model_class or @form_model_name is required")
      @form_model_name = @model_class.to_s.underscore
    end
    @form_model_name
  end

  def object_for_edit
    unless @object_for_edit
      assert_not_nil(@model_class, "@model_class is required")
      @object_for_edit = send(model_class.table_name, relevance_crud_fixture)
    end
    @object_for_edit
  end

  def object_for_create
    unless @object_for_create
      assert_not_nil(object_for_edit)
      @object_for_create = object_for_edit.class.new
      attributes_for_create = object_for_edit.attributes
      attributes_for_create.delete('id')
      @object_for_create.attributes = @object_for_create.attributes.merge(attributes_for_create)      
    end
    @object_for_create
  end
  
  def stub_instances(clazz, allocator, receives, returns)
    flexstub(clazz).new_instances(allocator) do |new_model|
      new_model.should_receive(receives).and_return(returns)
    end
  end
  
  def model_validations_fail_for(allocator, *args)
    if args.empty?
      assert_not_nil(@model_class, "@model_class is required")
      args << model_class 
    end
    args.each do |arg|
      stub_instances(arg,allocator,:valid?,false)
    end
  end
  
  def model_validations_succeed_for(allocator, *args)
    if args.empty?
      assert_not_nil(@model_class, "@model_class is required")
      args << model_class 
    end
    args.each do |arg|
      args.each do |arg|
        stub_instances(arg,allocator,:valid?,true)
        stub_instances(arg,allocator,:validate,true)
      end
    end
  end
  
  def url_for_list
    url_for(url_base.merge(:action=>'list'))
  end
  
  def url_for_new
    url_for(url_base.merge(:action=>'new'))
  end

  def url_for_destroy
    url_for(url_base.merge(:action=>'destroy'))
  end
  
  def url_for_create
    assert_not_nil(object_for_create)
    url_for(url_base.merge(:action => 'create'))
  end
  
  def url_for_edit
    assert_not_nil(object_for_edit)
    url_for(url_base.merge(:action => 'edit', :id => object_for_edit))
  end
  
  def url_for_update
    assert_not_nil(object_for_edit)
    url_for(url_base.merge(:action => 'update', :id => object_for_edit))
  end

  def url_for_delete
    assert_not_nil(object_for_edit)
    url_for(url_base.merge(:action => 'delete', :id => object_for_edit))
  end
  
end

