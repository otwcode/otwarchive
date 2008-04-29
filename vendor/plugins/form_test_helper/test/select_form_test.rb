require File.join(File.dirname(__FILE__), "test_helper")

class SelectFormTest < Test::Unit::TestCase
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::TagHelper
  include XHRHelpers
    
  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_select_form
    render_html %Q{<form id="test"></form>}
    assert_select "form#?", "test"
    form = select_form "test"
    assert_equal FormTestHelper::Form, form.class
    
    assert_raise(Test::Unit::AssertionFailedError) do
      select_form 'nonexistent'
    end
  end
  
  def test_select_form_with_multiple_submits_where_the_submit_value_exists
    render_html %|
      <form id="test">
        <input type="submit" value="yes" />
        <input type="submit" value="no" />
      </form>|
    assert_select "form#?", "test"
    form = select_form "test", :submit_value => "yes"
    assert_equal FormTestHelper::Form, form.class
  end
  
  def test_select_form_with_multiple_submits_where_the_submit_value_does_not_exist
    render_html %|
      <form id="test">
        <input type="submit" value="Yes" name="yes"/>
        <input type="submit" value="No" name="no" /><
      /form>|
    assert_select "form#test"
    form = select_form "test", :submit_value => "Cancel"
    assert_equal FormTestHelper::Form, form.class
    
    assert_raise(Test::Unit::AssertionFailedError) do
      select_form 'nonexistent'
    end
  end

  def test_select_form_when_enclosed
    render_html %Q{<div><form id="test"></form></div>}
    select_form "test"
  end
  
  def test_select_form_by_action
    render_html %Q{<form action="/test"></form>}
    select_form "/test"
  end
  
  def test_select_only_form
    render_html %Q{<form></form>}
    select_form
  
    render_html %Q{<form id="one"></form><form id="two"></form>}
    assert_raise(Test::Unit::AssertionFailedError) { select_form }
  end
    
  def test_selected_form_submits_to_action
    render_rhtml %Q{<%= form_tag({:action => 'create'}) + submit_tag + "</form>" %>}
    form = select_form "/test/create"
    form.submit
    assert_action_name :create
    assert_equal :post, @request.method
  end
  
  def test_selected_form_submits_to_self_when_no_action
    render_html %Q{<form id="self"></form>}
    form = select_form "self"
    
    @controller.response_with = "Form submitted."
    form.submit_without_clicking_button
    assert_action_name :html
    assert_equal "Form submitted.", @response.body
    assert_equal :get, @request.method # Firefox uses GET when no method specified
  end
  
  def test_selected_form_submits_with_restful_request_method
    render_rhtml %Q{<%= form_tag({:action => "destroy"}, {:method => :delete}) %></form>}
    form = select_form "/test/destroy"
    form.submit_without_clicking_button
    assert_response :success
    assert_action_name :destroy
    assert_equal :delete, @request.method
  end
  
  def test_submit_to_another_controller
    render_rhtml <<-EOD
      <%= form_tag(:controller => 'other') %>
        <%= submit_tag %>
      </form>
    EOD
    select_form.submit
  end
  
  def test_form_has_fields_hash
    render_rhtml <<-EOD
      <%= form_tag %>
        <%= text_field_tag "person[address][city]", "Anytown" %>
      </form>
    EOD
    form = select_form
    assert_not_nil form.fields_hash
    assert_kind_of FormTestHelper::FieldsHash, form.fields_hash[:person]
    assert_equal form.fields_hash[:person], form.fields_hash["person"]
    assert_kind_of FormTestHelper::FieldsHash, form.fields_hash[:person][:address]
    assert_equal "Anytown", form.fields_hash[:person][:address][:city].value
    assert_kind_of FormTestHelper::Field, form.fields_hash[:person][:address][:city]
  end
  
  def test_fields_accessible_by_methods_on_form
    render_rhtml <<-EOD
      <%= form_tag %>
        <%= text_field_tag "person[address][city]", "Anytown" %>
      </form>
    EOD
    form = select_form
    assert_not_nil form.fields_hash
    assert_kind_of FormTestHelper::FieldsHash, form.person
    assert_kind_of FormTestHelper::FieldsHash, form.person.address
    assert_equal "Anytown", form.person.address.city
    assert_kind_of String, form.person.address.city
    form.person.address.city = 'Managua'
    assert_raise(FormTestHelper::FieldsHash::FieldNotFoundError) { form.person.name }
  end

  def test_fields_accessible_by_keys_on_form
    render_rhtml <<-EOD
      <%= form_tag %>
        <%= text_field_tag "person[address][city]", "Anytown" %>
      </form>
    EOD
    form = select_form
    assert_not_nil form.fields_hash
    assert_kind_of FormTestHelper::FieldsHash, form.person
    assert_kind_of FormTestHelper::FieldsHash, form.person.address
    assert_equal "Anytown", form.person.address.city
    assert_kind_of String, form.person.address.city
    form.person.address['city'] = 'Managua'
    assert_equal 'Managua', form.person.address.city.value
    assert_raise(FormTestHelper::FieldsHash::FieldNotFoundError) { form.person.name }
  end
  
  def test_fields_accessible_by_methods_on_form_act_as_proxy
    render_rhtml <<-EOD
      <%= form_tag %>
        <%= text_field_tag "person[address][city]" %>
        <%= select_tag 'number[]', %q{<option>0</option><option>1</option>}, :multiple => true %>
      </form>
    EOD
    form = select_form
    assert_kind_of String, form.person.address.city
    assert_nothing_raised { form.person.address.city.tag }
    assert_kind_of Array, form.number
    assert_nothing_raised { form.number.tag }
  end
  
  def test_reset_form
    render_rhtml <<-EOD
      <%= form_tag %>
        <%= text_field_tag "text", "1" %>
      </form>
    EOD
    form = select_form
    form['text'] = '2'
    assert_equal '2', form['text'].value
    form.reset
    assert_equal '1', form['text'].value
  end
  
  def test_reset_field
    render_rhtml <<-EOD
      <%= form_tag %>
      <%= check_box_tag "checkbox", "1", false %>
        <%= text_field_tag "text", "0" %>
      </form>
    EOD
    form = select_form
    form['text'] = '1'
    form['checkbox'] = '1'
    assert_equal '1', form['text'].value
    assert_equal '1', form['checkbox'].value
    form['text'].reset
    assert_equal '0', form['text'].value
    assert_equal '1', form['checkbox'].value
  end
  
  def test_field_passes_methods_to_tag
    render_rhtml <<-EOD
      <%= form_tag %>
        <%= text_field_tag "name", "Jason", :class => 'field' %>
      </form>
    EOD
    form = select_form
    assert_equal "field", form['name'].attributes['class']
  end
  
  def test_fields
    render_rhtml <<-EOD
      <%= form_tag %>
        <%= text_area_tag "textarea", "value" %>
        <span><%= text_field_tag "text", "value" %></span>
        <%= select_tag "people", "<option>Jason</option>" %>
        <button name="submit">Submit</button>
        
        <hr>
        <input />
        <textarea></textarea>
        <div>&nbsp;</div>
      </form>
    EOD
    form = select_form
    assert_equal 4, form.fields.size
  end
  
  def test_missing_field
    render_rhtml <<-EOD
      <%= form_tag %></form>
    EOD
    assert_raise(FormTestHelper::Form::FieldNotFoundError) { select_form['username'] }
    assert_raise(FormTestHelper::Form::FieldNotFoundError) { select_form.username }
  end
  
  def test_missing_field_when_updating_value
    render_rhtml <<-EOD
      <%= form_tag %></form>
    EOD
    assert_raise(FormTestHelper::Form::FieldNotFoundError) { select_form['username'] = 'bob' }
    assert_raise(FormTestHelper::Form::FieldNotFoundError) { select_form.username = 'bob' }
  end
  
  def test_submit
    value = "jason"
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field_tag "username", "#{value}" %>
        <%= submit_tag %>
      </form>
    EOD
    form = select_form
    form.submit
    assert_response :success
    assert_equal value, @controller.params[:username]
    assert_equal({"commit"=>"Save changes", "username"=>value, "action"=>"create", "controller"=>@controller.controller_name}, @controller.params)
  end

  def test_submit_with_multiple_submit_values_submitting_yes
    value = "jason"
    render_rhtml <<-EOD
      <%= form_tag({:action => 'create'}, {:id => "test" }) %>
        <%= text_field_tag "username", "#{value}" %>
        <%= submit_tag "Yes", :value => "yes" %>
        <%= submit_tag "No", :value => "no" %>
      </form>
    EOD
    form = select_form "test", :submit_value => "yes"
    form.submit
    assert_response :success
    assert_equal value, @controller.params[:username]
    assert_equal({"commit"=>"yes", "username"=>value, "action"=>"create", "controller"=>@controller.controller_name}, @controller.params)
  end

  def test_submit_with_multiple_submit_values_submitting_no
    value = "jason"
    render_rhtml <<-EOD
      <%= form_tag({:action => 'create'}, {:id => "test" }) %>
        <%= text_field_tag "username", "#{value}" %>
        <%= submit_tag "Yes", :value => "yes" %>
        <%= submit_tag "No", :value => "no" %>
      </form>
    EOD
    form = select_form "test", :submit_value => "no"
    form.submit
    assert_response :success
    assert_equal value, @controller.params[:username]
    assert_equal({"commit"=>"no", "username"=>value, "action"=>"create", "controller"=>@controller.controller_name}, @controller.params)
  end
    
  def test_submit_by_xhr_without_a_block
    render_for_xhr
    new_value = 'brent'
    form = select_form :xhr => true
    form.username = new_value
    form.submit
    check_xhr_responses new_value
  end
    
          
  def test_text_field
    assert_select_form_works_with "article[name]", "My article" do |name, value|
      text_field_tag name, value
    end
  end
  
  def test_text_area
    assert_select_form_works_with "article[body]", "This is <em>great</em>!" do |name, value|
      text_area_tag name, value
    end
  end
  
  def test_hidden_value_is_protected
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <input type="hidden" name="key" value="12345" />
        <%= submit_tag %>
      </form>
    EOD
    form = select_form
    assert_raise(TypeError) { form["key"] = "9876" }
    form["key"].set_value("6789")
    form.submit
    assert_response :success
    assert_equal({"commit"=>"Save changes", "key"=>"6789", "action"=>"create", "controller"=>@controller.controller_name}, @controller.params)
  end
  
  def test_checkbox_tag
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <input type="checkbox" name="ok" value="1" />
      </form>
    EOD
    form = select_form
    form.submit_without_clicking_button
    assert_nil @controller.params["ok"] # Checkboxes are nil when unchecked unless they have a hidden field by the same name
    
    form["ok"].check
    form.submit_without_clicking_button
    assert_equal "1", @controller.params["ok"]
  end
  
  def test_check_box_takes_boolean_values
    # @article is an object set up in test_helper.rb
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= check_box "article", "published" %>
        <%= submit_tag %>
      </form>
    EOD
    form = select_form
    form.submit("article" => {"published" => true})
    assert_equal "1", @controller.params["article"]['published']
    
    form.submit("article" => {"published" => false})
    assert_equal "0", @controller.params["article"]['published']
  end
  
  def test_check_box_prevents_setting_nonexistent_values
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= check_box "article", "published" %>
        <%= submit_tag %>
      </form>
    EOD
    form = select_form
    assert_raise(RuntimeError) { form.article.published = "perhaps" }
    assert_raise(RuntimeError) { form.submit("article" => {"published" => "perhaps"}) }
  end
  
  def test_check_box_initially_checked
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= check_box "article", "written" %>
      </form>
    EOD
    assert_equal true, assigns(:article).written
    form = select_form
    form.submit_without_clicking_button
    assert_equal "1", @controller.params["article"]['written']
    
    form["article[written]"].uncheck
    form.submit_without_clicking_button
    assert_equal "0", @controller.params["article"]["written"]
  end
  
  def test_check_box_unchecked
    # The check_box_tag helper creates both a checkbox and a hidden field
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= check_box "article", "published" %>
      </form>
    EOD
    assert_equal false, assigns(:article).published
    form = select_form
    form.submit_without_clicking_button
    assert_equal "0", @controller.params["article"]['published']
    
    form["article[published]"].check
    form.submit_without_clicking_button
    assert_equal "1", @controller.params["article"]['published']
  end
  
  def test_radio_button
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= radio_button_tag "gender", "female", true %>
        <%= radio_button_tag "gender", "male" %>
      </form>
    EOD
    form = select_form
    assert_equal %w(female male), form['gender'].options
    assert_equal 'female', form['gender'].value
    form['gender'] = 'male'
    form.submit_without_clicking_button
    assert_equal 'male', @controller.params['gender']
  end
  
  def test_radio_buttons_when_none_checked
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= radio_button_tag "gender", "female" %>
        <%= radio_button_tag "gender", "male" %>
      </form>
    EOD
    form = select_form
    assert_equal %w(female male), form['gender'].options
    form.submit_without_clicking_button
    assert_nil @controller.params["gender"]
  end
  
  def test_radio_buttons_when_multiple_checked
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= radio_button_tag "gender", "female", true %>
        <%= radio_button_tag "gender", "male", true %>
      </form>
    EOD
    form = select_form
    assert_equal %w(female male), form['gender'].options
    assert_equal form['gender'].options.last, form['gender'].value
    form.submit_without_clicking_button
    assert_equal 'male', @controller.params['gender']
  end
  
  def test_radio_buttons_prevent_setting_nonexistent_values
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= radio_button_tag "gender", "female", true %>
        <%= radio_button_tag "gender", "male" %>
        <%= submit_tag %>
      </form>
    EOD
    form = select_form
    assert_equal %w(female male), form['gender'].options
    assert_raise(RuntimeError) { form.gender = "neuter" }
    assert_raise(RuntimeError) { form.submit('gender' => "neuter") }
  end
  
  def test_select
    assert_select_form_works_with("people", "0") do |name, value|
      select_tag name, %q{<option selected="selected">0</option><option>1</option>}
    end
  end
  
  def test_select_multiple_requires_square_brackets
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= select_tag 'defunct_multiple_select', '', :multiple => true %>
      </form>
    EOD
    assert_raise(FormTestHelper::SelectMultiple::NameMissingSquareBracketsError) { select_form.defunct_multiple_select }
  end
  
  def test_select_multiple_can_be_found_with_square_brackets
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= select_tag 'multiple_select[]', '<option selected="selected">0</option>', :multiple => true %>
      </form>
    EOD
    form = select_form
    assert_equal ['0'], form['multiple_select[]'].value # The field's name is "multiple_select" but this works for convenience
    assert_equal ['0'], form['multiple_select'].value
    assert_equal ['0'], form.multiple_select
  end
  

  def test_initially_selected_value_of_select_multiple
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= select_tag 'none_selected[]', %q{<option>0</option><option>1</option>}, :multiple => true %>
        <%= select_tag 'one_selected[]', %q{<option selected="selected">0</option><option>1</option>}, :multiple => true %>
        <%= select_tag 'all_selected[]', %q{<option selected="selected">0</option><option selected="selected">1</option>}, :multiple => true %>
      </form>
    EOD
    form = select_form
    [:none_selected, :one_selected, :all_selected].each do |field_name|
      assert_equal %w(0 1), form[field_name].options
    end
    assert_equal [], form.none_selected
    assert_equal %w(0), form.one_selected
    assert_equal %w(0 1), form.all_selected
    
    form.submit_without_clicking_button
    assert_nil @controller.params[:none_selected]
    assert_equal %w(0), @controller.params[:one_selected]
    assert_equal %w(0 1), @controller.params[:all_selected]
  end
  
  def test_can_set_select_multiple_value_with_array
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= select_tag 'number[]', %q{<option>0</option><option>1</option>}, :multiple => true %>
      </form>
    EOD
    form = select_form
    assert_equal %w(0 1), form.number.options
    form.number = form.number.options
    assert_equal %w(0 1), form.number
    form.submit_without_clicking_button
    assert_equal %w(0 1), @controller.params['number']
  end
  
  def test_select_with_multiple_initially_selected_but_not_allowed
    render_rhtml <<-EOD
      <%= form_tag %>
        #{select_tag 'number', %q{<option selected="selected">0</option><option selected="selected">1</option>}}
      </form>
    EOD
    form = select_form
    assert_equal %w(0 1), form['number'].options
    assert_equal '1', form['number'].value # Browsers generally pick the last when multiple selected
  end
  
  def test_select_with_labeled_options_by_label
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        #{select_tag 'person_id', %q{<option selected="selected" value="1">Jason</option><option value="2">Brent</option>}}
      </form>
    EOD
    form = select_form
    assert_equal [['Jason', '1'], ['Brent', '2']], form['person_id'].options
    assert_equal '1', form['person_id'].value
    form['person_id'] = "Brent"
    assert_equal '2', form['person_id'].value
    form.submit_without_clicking_button
    assert_equal '2', @controller.params['person_id']
  end
  
  def test_select_with_labeled_options_by_value
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        #{select_tag 'person_id', %q{<option selected="selected" value="1">Jason</option><option value="2">Brent</option>}}
      </form>
    EOD
    form = select_form
    form['person_id'] = 2
    assert_equal '2', form['person_id'].value
    form.submit_without_clicking_button
    assert_equal '2', @controller.params['person_id']
  end
  
  def test_select_default_with_labeled_options
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        #{select_tag 'person_id', %q{<option value="1">Jason</option><option value="2">Brent</option>}}
      </form>
    EOD
    form = select_form
    assert_equal '1', form['person_id'].value
    form.submit_without_clicking_button
    assert_equal '1', @controller.params['person_id']
  end
  
  def test_select_with_identically_labeled_options
    render_rhtml <<-EOD
      <%= form_tag %>
        #{select_tag 'country', %q{<option selected="selected" value="US">US</option><option value="Canada">Canada</option>}}
      </form>
    EOD
    form = select_form
    assert_equal ['US', 'Canada'], form['country'].options
  end
  
  def test_select_form_accepts_block
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field_tag "username", "jason" %>
        <%= submit_tag %>
      </form>
    EOD
    new_value = 'brent'
    f = select_form do |form|
      form['username'] = new_value
    end
    f.submit
    assert_response :success
    assert_equal new_value, @controller.params[:username]
  end
  

  protected
  
  def assert_select_form_works_with(name, value)
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        #{yield name, value}
        <%= submit_tag %>
      </form>
    EOD
    form = select_form
    assert_equal 2, form.fields.size
    assert_kind_of(FormTestHelper::Field, form[name])
    
    assert_equal value, form[name].initial_value
    assert_equal value, form[name].value
    assert_equal value, form.send(name)
    
    new_value = "1"
    form[name] = new_value
    assert_equal new_value, form[name].value
    form.submit
    assert_response :success
    
    expected_params = {"commit"=>"Save changes", "action"=>"create", "controller"=>@controller.controller_name}
    if name =~ /(.*)\[(.*)\]/
      object = $1
      method = $2
      expected_params.merge!(object=>{method => new_value})
    else
      expected_params.merge!(name => new_value)
    end
    
    assert_equal(expected_params, @controller.params)
  end

  def test_submit_accepts_and_updates_field_values
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field_tag "username", "jason" %>
        <%= text_field_tag "account[status]", "closed" %>
        <%= submit_tag %>
      </form>
    EOD
    form = select_form
    new_value = 'brent'
    form.submit :username => new_value
    assert_response :success
    assert_equal new_value, @controller.params[:username]

    form.submit :account => {:status => 'open'}
    assert_response :success
    assert_equal 'open', @controller.params[:account][:status]
  end

end
