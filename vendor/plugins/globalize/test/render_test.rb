require File.dirname(__FILE__) + '/test_helper'

class RenderController < ActionController::Base
  def test() render :action => 'test'; end

  def rescue_action(e) raise; end
end

RenderController.prepend_view_path(File.dirname(__FILE__) + "/views") 

class RenderControllerTest < Test::Unit::TestCase
  include Globalize
  fixtures :globalize_languages, :globalize_countries

  def setup
    Locale.set("en-US")
    @controller = RenderController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  def test_rendered_action
    get :test
    assert @response.rendered_with_file?
    assert 'test', @response.rendered_file
    assert_template 'test'
  end
end