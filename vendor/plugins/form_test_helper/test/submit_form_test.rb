require File.join(File.dirname(__FILE__), "test_helper")

class SubmitFormTest < Test::Unit::TestCase
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::TagHelper
  include XHRHelpers
    
  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_submit_to_namespaced_controller
	  @controller = Admin::NamespacedController.new
    value = "jason"
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field_tag "username", "#{value}" %>
        <%= submit_tag %>
      </form>
    EOD
    submit_form
    assert_response :success
    assert_equal value, @controller.params[:username]
  end
  
  def test_submit_requires_submit_tag
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field_tag "username", "jason" %>
      </form>
    EOD
    assert_raise(FormTestHelper::Form::MissingSubmitError) { submit_form }
    
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <BUTTON name="submit" value="submit" type="submit">Submit</BUTTON>
      </form>
    EOD
    assert_nothing_raised { submit_form }
    
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <input type="submit">
      </form>
    EOD
    assert_nothing_raised { submit_form }
    
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= image_submit_tag 'image.png' %>
      </form>
    EOD
    assert_nothing_raised { submit_form }
  end
  
  def test_submit_requires_submit_tag_with_value
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field_tag "username", "jason" %>
      </form>
    EOD
    assert_raise(FormTestHelper::Form::MissingSubmitError) { submit_form :submit_value => "yes" }
    
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <BUTTON name="submit" value="yes" type="submit">Submit</BUTTON>
      </form>
    EOD
    assert_nothing_raised { submit_form :submit_value => "yes"  }

    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <BUTTON name="submit" value="no" type="submit">Submit</BUTTON>
      </form>
    EOD
    assert_raise(FormTestHelper::Form::MissingSubmitError) { submit_form :submit_value => "yes"  }
    
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <input type="submit" value="yes">
      </form>
    EOD
    assert_nothing_raised { submit_form :submit_value => "yes"  }

    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <input type="submit" value="no">
      </form>
    EOD
    assert_raise(FormTestHelper::Form::MissingSubmitError) { submit_form :submit_value => "yes"  }
    
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= image_submit_tag 'image.png', :value => "yes" %>
      </form>
    EOD
    assert_nothing_raised { submit_form }    

    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= image_submit_tag 'image.png', :value => "no" %>
      </form>
    EOD
    assert_raise(FormTestHelper::Form::MissingSubmitError) { submit_form :submit_value => "yes"  }

  end
  
  def test_submit_form_accepts_block
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field_tag "username", "jason" %>
        <%= submit_tag %>
      </form>
    EOD
    new_value = 'brent'
    submit_form do |form|
      form['username'] = new_value
    end
    assert_response :success
    assert_equal new_value, @controller.params[:username]
  end
  
  def test_submit_form_without_block_selects_and_submits
    html = <<-EOD
      <%= form_tag({:action => 'create'}, {:id => :test}) %>
        <%= text_field_tag "username", "jason" %>
        <%= submit_tag %>
      </form>
    EOD
    render_rhtml html
    submit_form
    assert_response :success
    assert_equal 'jason', @controller.params[:username]
    
    render_rhtml html
    assert_select "form#?", "test"
    new_value = 'brent'
    submit_form "test", :username => new_value
    assert_response :success
    assert_equal new_value, @controller.params[:username]
    
    render_rhtml html
    new_value = 'david'
    submit_form :username => new_value
    assert_response :success
    assert_equal new_value, @controller.params[:username]
  end
    
  def test_submit_form_sets_referrer_header
    render_rhtml <<-EOD
      <%= form_tag(:action => 'redirect_to_back') %>
        <%= submit_tag %>
      </form>
    EOD
    
    submit_form
    assert_response :redirect
    assert_redirected_to :action => 'rhtml'
  end
  
  def test_submit_form_by_xhr_using_a_block
    render_for_xhr
    new_value = 'brent'
    submit_form :xhr => true do | form |
      form['username'] = new_value
    end
    check_xhr_responses new_value
  end

  def test_accessing_simple_field_by_method_call
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field_tag "username", "jason" %>
        <%= submit_tag %>
      </form>
    EOD
    new_value = 'brent'
    submit_form do |form|
      assert_equal 'jason', form.username
      form.username = new_value
    end
    assert_response :success
    assert_equal new_value, @controller.params[:username]
  end
  
  def test_accessing_deep_field_by_method_call
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field_tag "user[username]", "jason" %>
        <%= submit_tag %>
      </form>
    EOD
    new_value = 'brent'
    submit_form do |form|
      assert_equal 'jason', form.user.username
      form.user.username = new_value
    end
    assert_response :success
    assert_equal new_value, @controller.params[:user][:username]
  end
  
  def test_accessing_field_as_keys
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field_tag "user[username]", "jason" %>
        <%= submit_tag %>
      </form>
    EOD
    new_value = 'brent'
    submit_form do |form|
      assert_equal 'jason', form.user.username
      form.user['username'] = new_value
    end
    assert_response :success
    assert_equal new_value, @controller.params[:user][:username]    
  end

  def test_accessing_nonexistant_fields_as_keys_raises_exceptions
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= submit_tag %>
      </form>
    EOD
    assert_raise(FormTestHelper::Form::FieldNotFoundError) do 
      submit_form do |form|
        assert_equal 'jason', form.user.username
        form.user['username'] = new_value
      end
    end
  end
  
  def test_with_object
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field :book, :name %>
        <%= select :book, :category, [['Mining', 1], ['Programming', 2]] %>
        <%= check_box :book, :classic %>
        <%= submit_tag %>
      </form>
    EOD
    submit_form do |form|
      form.with_object(:book) do |book|
        book.name = 'Pickaxe'
        book.category = 'Programming'
        book.classic.check
      end
    end
    assert_response :success
    assert_equal 'Pickaxe', @controller.params[:book][:name]
  end
  
  def test_updating_fields_with_hash
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= text_field :book, :name %>
        <%= select :book, :category, [['Mining', 1], ['Programming', 2]] %>
        <%= check_box :book, :classic %>
        <%= submit_tag %>
      </form>
    EOD
    new_book = {
      :name => 'Pickaxe',
      :category => '2', # Could assign "Programming", but then it won't equal 2 in the params.
      :classic => '1'
    }
    submit_form do |form|
      form.book.update(new_book)
    end
    assert_response :success

    new_book.each do |attribute,expects|
      assert_equal expects, @controller.params[:book][attribute]
    end
  end
  
  def test_submit_form_sets_response_body
    render_rhtml <<-EOD
      <%= form_tag(:action => 'create') %>
        <%= submit_tag %>
      </form>
    EOD
    submit_form  
    assert_equal "created", @response.body
  end
  
  def test_submit_form_with_multiple_submit_values_submitting_with_a_block
    value = "jason"
    render_rhtml <<-EOD
      <%= form_tag({:action => 'create'}, {:id => "test" }) %>
        <%= text_field_tag "username", "#{value}" %>
        <%= submit_tag "Yes", :value => "yes" %>
        <%= submit_tag "No", :value => "no" %>
        <%= submit_tag "Maybe", :value => "maybe" %>
      </form>
    EOD
    form = submit_form "test", :submit_value => "maybe" do |form|
    end
    assert_response :success
    assert_equal value, @controller.params[:username]
    assert_equal({"commit"=>"maybe", "username"=>value, "action"=>"create", "controller"=>@controller.controller_name}, @controller.params)
  end

  def test_submit_form_with_multiple_submit_values_submitting_without_a_block
    value = "jason"
    render_rhtml <<-EOD
      <%= form_tag({:action => 'create'}, {:id => "test" }) %>
        <%= text_field_tag "username", "#{value}" %>
        <%= submit_tag "Yes", :value => "yes" %>
        <%= submit_tag "No", :value => "no" %>
        <%= submit_tag "Maybe", :value => "maybe" %>
      </form>
    EOD
    form = submit_form "test", :submit_value => "maybe"
    assert_response :success
    assert_equal value, @controller.params[:username]
    assert_equal({"commit"=>"maybe", "username"=>value, "action"=>"create", "controller"=>@controller.controller_name}, @controller.params)
  end
    
end