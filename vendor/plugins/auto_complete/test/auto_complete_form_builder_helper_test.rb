require 'helper'

class Person
  attr_accessor :name, :id
  def initialize name, id = nil
    @name, @id = name, id
  end
  def to_param
    id.to_s
  end
end

class AutoCompleteFormBuilderHelperTest < Test::Unit::TestCase

  include AutoCompleteMacrosHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormHelper

  def setup

    @existing_person = Person.new "Existing Person", 1234
    @person = Person.new "New Person"

    controller_class = Class.new do
      def url_for(options)
        url =  "http://www.example.com/"
        url << options[:action].to_s if options and options[:action]
        url
      end
    end
    @controller = controller_class.new
    
  end

  def test_auto_complete_field_in_normal_form_does_not_have_random_id
    _erbout = ''
    fields_for(@person) do |f|
      _erbout = f.text_field_with_auto_complete(:name)
    end
    assert _erbout.index('id="person_name"')
  end

  def test_compare_to_macro_in_normal_form
    standard_auto_complete_html = text_field_with_auto_complete(:person, :name)

    _erbout = ''
    fields_for(@person) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name)
      assert_equal 'person', f.class_name
    end
    assert_equal standard_auto_complete_html, _erbout.gsub(/paramName:'person\[name\]'/, '')
  end

  def test_compare_to_macro_in_normal_form_with_symbol
    standard_auto_complete_html = text_field_with_auto_complete(:some_class, :name)

    _erbout = ''
    fields_for(:some_class) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name)
      assert_equal 'some_class', f.class_name
    end
    assert_equal standard_auto_complete_html, _erbout.gsub(/paramName:'some_class\[name\]'/, '')
  end

  def test_two_auto_complete_fields_in_nested_form_have_different_ids
    id_attribute_pattern = /id=\"[^\"]*\"/i
    _erbout = ''
    _erbout2 = ''
    fields_for('group[person_attributes][]', @person) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name)
      _erbout2.concat f.text_field_with_auto_complete(:name)
    end
    assert_equal [], _erbout.scan(id_attribute_pattern) & _erbout2.scan(id_attribute_pattern)
  end

  def test_compare_macro_to_fields_for_in_nested_form
    standard_auto_complete_html = text_field_with_auto_complete(:person, :name)

    _erbout = ''
    fields_for('group[person_attributes][]', @person) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name)
    end

    assert_equal standard_auto_complete_html,
      _erbout.gsub(/group\[person_attributes\]\[\]/, 'person').gsub(/person_[0-9]+_name/, 'person_name').gsub(/paramName:'person\[name\]'/, '')
  end
  
  def test_ajax_url
    _erbout = ''
    fields_for('group[person_attributes][]', @person) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name)
    end
    assert _erbout.index('http://www.example.com/auto_complete_for_person_name')
  end
  
  def test_ajax_param
    _erbout = ''
    fields_for('group[person_attributes][]', @person) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name)
    end
    assert _erbout.index("{paramName:'person[name]'}")
  end
  
  def test_object_value
    _erbout = ''
    fields_for('group[person_attributes][]', @existing_person) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name)
    end
    assert _erbout.index('value="Existing Person"')
  end
  
  def test_auto_index_value_for_existing_record
    _erbout = ''
    fields_for('group[person_attributes][]', @existing_person) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name)
    end
    assert _erbout.index("[1234]")
  end
  
  def test_auto_index_value_for_new_record
    _erbout = ''
    fields_for('group[person_attributes][]', @person) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name)
    end
    assert _erbout.index("[]")
  end

  def test_child_index_fields_for_option
    _erbout = ''
    fields_for 'group[person_attributes][]', @person, { :child_index => 5678 } do |f|
      _erbout.concat f.text_field_with_auto_complete(:name, {}, { :method => :get })
      assert _erbout.index('person_5678_name')
    end
  end

  def test_child_index_completion_option
    _erbout = ''
    fields_for('group[person_attributes][]', @person) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name, {}, { :method => :get, :child_index => 1234 })
      assert _erbout.index('person_1234_name')
    end
  end

  def test_child_index_completion_option_overrides_fields_for_option
    _erbout = ''
    fields_for('group[person_attributes][]', @person, { :child_index => 5678 }) do |f|
      _erbout.concat f.text_field_with_auto_complete(:name, {}, { :method => :get, :child_index => 1234 })
      assert _erbout.index('person_1234_name')
    end
  end
end
