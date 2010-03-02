require 'helper'

# Note: These tests require nested attributes (Rails 2.3 or greater).

Object.const_set("ParentTestModel", Class.new(ActiveRecord::Base))
Object.const_set("ChildTestModel", Class.new(ActiveRecord::Base))

ActiveRecord::Base.connection.create_table :parent_test_models, :force => true do |table|
  table.column :name, :string
end

ActiveRecord::Base.connection.create_table :child_test_models, :force => true do |table|
  table.column :name, :string
end

ParentTestModel.class_eval do
  has_many :child_test_models
  accepts_nested_attributes_for :child_test_models, :allow_destroy => true
end

ChildTestModel.class_eval do
  belongs_to :parent_test_model
end

class AutoCompleteNestedAttributesTest < Test::Unit::TestCase

  include AutoCompleteMacrosHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormHelper

  def setup

    @parent = ParentTestModel.new :name => 'Name of existing parent model'
    3.times do |i|
      @parent.child_test_models.build :name => "Name of child model #{i}"
    end

    controller_class = Class.new do
      def url_for(options)
        url =  "http://www.example.com/"
        url << options[:action].to_s if options and options[:action]
        url
      end
    end
    @controller = controller_class.new
    
  end
  
  def test_nested_attributes_all_have_different_ids
    id_attribute_pattern = /id=\"[^\"]*\"/i
    _erbout = []
    fields_for @parent do |parent_form|
      parent_form.fields_for :child_test_models do |child_form|
        _erbout << child_form.text_field_with_auto_complete(:name, {}, { :method => :get })
      end
    end
    assert_equal [], _erbout[0].scan(id_attribute_pattern) & _erbout[1].scan(id_attribute_pattern)
    assert_equal [], _erbout[0].scan(id_attribute_pattern) & _erbout[2].scan(id_attribute_pattern)
    assert_equal [], _erbout[1].scan(id_attribute_pattern) & _erbout[2].scan(id_attribute_pattern)
  end

  def test_ajax_url
    _erbout = ''
    fields_for @parent do |parent_form|
      parent_form.fields_for :child_test_models do |child_form|
        _erbout.concat child_form.text_field_with_auto_complete(:name, {}, { :method => :get })
      end
    end
    assert _erbout.index('http://www.example.com/auto_complete_for_child_test_model_name')
  end
  
  def test_ajax_param
    _erbout = ''
    fields_for @parent do |parent_form|
      parent_form.fields_for :child_test_models do |child_form|
        _erbout.concat child_form.text_field_with_auto_complete(:name, {}, { :method => :get })
      end
    end
    assert _erbout.index("paramName:'child_test_model[name]'")
  end

  def test_object_value
    _erbout = ''
    fields_for @parent do |parent_form|
      parent_form.fields_for :child_test_models do |child_form|
        _erbout.concat child_form.text_field_with_auto_complete(:name, {}, { :method => :get })
      end
    end
    3.times do |i|
      assert _erbout.index("value=\"Name of child model #{i}\"")
    end
  end

  def test_sanitized_object_name
    fields_for @parent do |parent_form|
      assert_equal 'parent_test_model',
                   parent_form.sanitized_object_name
      parent_form.fields_for :child_test_models, { :child_index => 1234 } do |child_form|
        assert_equal 'parent_test_model_child_test_models_attributes_1234',
                     child_form.sanitized_object_name
      end
                   
    end
  end

  def test_is_used_as_nested_attribute
    fields_for @parent do |parent_form|
      assert !parent_form.is_used_as_nested_attribute?
      parent_form.fields_for :child_test_models do |child_form|
        assert child_form.is_used_as_nested_attribute?
      end
    end
    fields_for 'parent[child_test_models_attributes][]', @parent do |rails_2_2_form|
      assert !rails_2_2_form.is_used_as_nested_attribute?
    end
  end

  def test_child_index_fields_for_option
    _erbout = ''
    fields_for @parent, { :child_index => 5678 } do |parent_form|
      _erbout.concat parent_form.text_field_with_auto_complete(:name, {}, { :method => :get })
      assert _erbout.index('parent_test_model_5678_name')
    end
  end

  def test_child_index_completion_option
    _erbout = ''
    fields_for @parent do |parent_form|
      _erbout.concat parent_form.text_field_with_auto_complete(:name, {}, { :method => :get, :child_index => 1234 })
      assert _erbout.index('parent_test_model_1234_name')
    end
  end

  def test_child_index_completion_option_overrides_fields_for_option
    _erbout = ''
    fields_for @parent, { :child_index => 5678 } do |parent_form|
      _erbout.concat parent_form.text_field_with_auto_complete(:name, {}, { :method => :get, :child_index => 1234 })
      assert _erbout.index('parent_test_model_1234_name')
    end
  end

end
