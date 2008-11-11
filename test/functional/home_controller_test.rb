require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase
  context "a database with a restricted and an unrestricted work" do
    setup do
      @work1 = create_work
      @work2 = create_work(:restricted => true)
    end
    context "if you are not logged in" do
      setup do
        get :index, :locale => 'en'
      end
      should_render_template :index
      should_assign_to :work_count, :equal => 1
    end
    context "when logged in" do
      setup do
        @user = create_user
        @request.session[:user] = @user 
        get :index, :locale => 'en'
      end
      should_render_template :index
      should_assign_to :work_count, :equal => 2
    end
  end
end
