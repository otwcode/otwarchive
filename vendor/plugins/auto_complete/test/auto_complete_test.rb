require 'helper'

ActionController::Routing::Routes.draw do |map|
  map.connect  ':controller/:action/:id'
end

class AutoCompleteTest < ActionController::TestCase
  include AutoComplete
  include AutoCompleteMacrosHelper
  
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::CaptureHelper
  include ActionController::Integration
  
  def setup
    @controller = Class.new(ActionController::Base) do

      auto_complete_for :some_model, :some_field

      auto_complete_for :some_model, :some_other_field do |items, params|
        items.scoped( { :conditions => [ "a_third_field = ?", params['some_model']['a_third_field'] ] })
      end

      attr_reader :items

      def url_for(options)
        url =  "http://www.example.com/"
        url << options[:action].to_s if options and options[:action]
        url
      end

      class << self
        def name
          'test_controller'
        end
      end
    end
    @controller = @controller.new

    Object.const_set("SomeModel", Class.new(ActiveRecord::Base)) unless Object.const_defined?("SomeModel")

    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

  end


  def test_auto_complete_field
    assert_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', 'http://www.example.com/autocomplete', {})\n//]]>\n</script>),
      auto_complete_field("some_input", :url => { :action => "autocomplete" });
    assert_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', 'http://www.example.com/autocomplete', {tokens:','})\n//]]>\n</script>),
      auto_complete_field("some_input", :url => { :action => "autocomplete" }, :tokens => ',');
    assert_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', 'http://www.example.com/autocomplete', {tokens:[',']})\n//]]>\n</script>),
      auto_complete_field("some_input", :url => { :action => "autocomplete" }, :tokens => [',']);  
    assert_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', 'http://www.example.com/autocomplete', {minChars:3})\n//]]>\n</script>),
      auto_complete_field("some_input", :url => { :action => "autocomplete" }, :min_chars => 3);
    assert_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', 'http://www.example.com/autocomplete', {onHide:function(element, update){alert('me');}})\n//]]>\n</script>),
      auto_complete_field("some_input", :url => { :action => "autocomplete" }, :on_hide => "function(element, update){alert('me');}");
    assert_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', 'http://www.example.com/autocomplete', {frequency:2})\n//]]>\n</script>),
      auto_complete_field("some_input", :url => { :action => "autocomplete" }, :frequency => 2);
    assert_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', 'http://www.example.com/autocomplete', {afterUpdateElement:function(element,value){alert('You have chosen: '+value)}})\n//]]>\n</script>),
      auto_complete_field("some_input", :url => { :action => "autocomplete" }, 
        :after_update_element => "function(element,value){alert('You have chosen: '+value)}");
    assert_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', 'http://www.example.com/autocomplete', {paramName:'huidriwusch'})\n//]]>\n</script>),
      auto_complete_field("some_input", :url => { :action => "autocomplete" }, :param_name => 'huidriwusch');
    assert_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nvar some_input_auto_completer = new Ajax.Autocompleter('some_input', 'some_input_auto_complete', 'http://www.example.com/autocomplete', {method:'get'})\n//]]>\n</script>),
      auto_complete_field("some_input", :url => { :action => "autocomplete" }, :method => :get);
  end
  
  def test_auto_complete_result
    result = [ { :title => 'test1'  }, { :title => 'test2'  } ]
    assert_equal %(<ul><li>test1</li><li>test2</li></ul>), 
      auto_complete_result(result, :title)
    assert_equal %(<ul><li>t<strong class=\"highlight\">est</strong>1</li><li>t<strong class=\"highlight\">est</strong>2</li></ul>), 
      auto_complete_result(result, :title, "est")
    
    resultuniq = [ { :title => 'test1'  }, { :title => 'test1'  } ]
    assert_equal %(<ul><li>t<strong class=\"highlight\">est</strong>1</li></ul>), 
      auto_complete_result(resultuniq, :title, "est")
  end
  
  def test_text_field_with_auto_complete
    assert_match %(<style type="text/css">),
      text_field_with_auto_complete(:message, :recipient)

    assert_equal %(<input id=\"message_recipient\" name=\"message[recipient]\" size=\"30\" type=\"text\" /><div class=\"auto_complete\" id=\"message_recipient_auto_complete\"></div><script type=\"text/javascript\">\n//<![CDATA[\nvar message_recipient_auto_completer = new Ajax.Autocompleter('message_recipient', 'message_recipient_auto_complete', 'http://www.example.com/auto_complete_for_message_recipient', {})\n//]]>\n</script>),
      text_field_with_auto_complete(:message, :recipient, {}, :skip_style => true)
  end
  
  # auto_complete_for :some_model, :some_field
  def test_default_auto_complete_for
    get :auto_complete_for_some_model_some_field, :some_model => { :some_field => "some_value" }
    default_auto_complete_find_options = @controller.items.proxy_options
    assert_equal "\"some_models\".some_field ASC", default_auto_complete_find_options[:order]
    assert_equal 10, default_auto_complete_find_options[:limit]
    assert_equal ["LOWER(\"some_models\".some_field) LIKE ?", "%some_value%"], default_auto_complete_find_options[:conditions]
  end

  # auto_complete_for :some_model, :some_other_field do |items, params|
  #   items.scoped( { :conditions => [ "a_third_field = ?", params['some_model']['a_third_field'] ] })
  # end
  def test_auto_complete_for_with_block
    get :auto_complete_for_some_model_some_other_field, :some_model => { :some_other_field => "some_value", :a_third_field => "some_value" }
    custom_auto_complete_find_options = @controller.items.proxy_options
    assert_equal [ "a_third_field = ?", 'some_value' ], custom_auto_complete_find_options[:conditions]

    default_auto_complete_scope = @controller.items.proxy_scope
    assert !default_auto_complete_scope.nil?
    default_auto_complete_find_options = default_auto_complete_scope.proxy_options
    assert_equal "\"some_models\".some_other_field ASC", default_auto_complete_find_options[:order]
    assert_equal 10, default_auto_complete_find_options[:limit]
    assert_equal ["LOWER(\"some_models\".some_other_field) LIKE ?", "%some_value%"], default_auto_complete_find_options[:conditions]
  end

  # Quoted table name seems to have changed in Rails 2.3...
  # For Rails 2.2 or earlier:

  # def test_default_auto_complete_for
  #   get :auto_complete_for_some_model_some_field, :some_model => { :some_field => "some_value" }
  #   default_auto_complete_find_options = @controller.items.proxy_options
  #   assert_equal "`some_models`.some_field ASC", default_auto_complete_find_options[:order]
  #   assert_equal 10, default_auto_complete_find_options[:limit]
  #   assert_equal ["LOWER(`some_models`.some_field) LIKE ?", "%some_value%"], default_auto_complete_find_options[:conditions]
  # end

  # def test_auto_complete_for_with_block
  #   get :auto_complete_for_some_model_some_other_field, :some_model => { :some_other_field => "some_value", :a_third_field => "some_value" }
  #   custom_auto_complete_find_options = @controller.items.proxy_options
  #   assert_equal [ "a_third_field = ?", 'some_value' ], custom_auto_complete_find_options[:conditions]
  # 
  #   default_auto_complete_scope = @controller.items.proxy_scope
  #   assert !default_auto_complete_scope.nil?
  #   default_auto_complete_find_options = default_auto_complete_scope.proxy_options
  #   assert_equal "`some_models`.some_other_field ASC", default_auto_complete_find_options[:order]
  #   assert_equal 10, default_auto_complete_find_options[:limit]
  #   assert_equal ["LOWER(`some_models`.some_other_field) LIKE ?", "%some_value%"], default_auto_complete_find_options[:conditions]
  # end

end
