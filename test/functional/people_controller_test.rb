require File.dirname(__FILE__) + '/../test_helper'

class PeopleControllerTest < ActionController::TestCase
  context "on GET to :index" do
    setup do
      assert @user = create_user
      get :index
    end
    should_assign_to :authors
    should_not_set_the_flash
    should_render_template :index
    should_respond_with :success
  end
end