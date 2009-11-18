require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  context "on POST to :edit someone else" do
    setup do
      assert @user = create_user
      assert @second_user = create_user
      @request.session[:user] = @second_user
      get :edit, :id => @user.login
    end
    should "not display a form" do
       assert_select "form", false
    end
    should_redirect_to("the first user's path") {user_path(@user)}
    should_set_the_flash_to /have permission/
  end
  context "on PUT to :update someone else" do
    setup do
      @new_about = random_paragraph
      assert @user = create_user
      assert @profile = create_profile
      assert @user.profile = @profile
      assert @second_user = create_user
      @request.session[:user] = @second_user
      put :update, :id => @user.login, :user => {"email" => @new_email}
    end
    should "not make the change" do
      assert_not_equal @new_email, @user.email
    end
    should_redirect_to("the first user's path") {user_path(@user)}
    should_set_the_flash_to /have permission/
  end

  context "on POST to :edit self" do
    setup do
      assert @user = create_user
      assert @request.session[:user] = @user
      get :edit, :id => @user.login
    end
    should_assign_to :user
    should "assign assign @user to user" do
      assert_equal @user, assigns(:user)
    end
    should_not_set_the_flash
    should_render_template :edit
    should_respond_with :success
  end

  context "on GET to :index" do
    setup do
      assert @user = create_user
      get :index
    end
    should_redirect_to("the people index") {people_path}
  end

  context "on DELETE of self" do
    setup do
      assert @user = create_user
      assert @request.session[:user] = @user
      delete :destroy, :id => @user.login
    end
    should "destroy the record" do
      assert_raises(ActiveRecord::RecordNotFound) { @user.reload }
    end
    should_redirect_to("the delete confirmation") {delete_confirmation_path}
  end
  context "on DELETE of someone else" do
    setup do
      assert @user = create_user
      assert @second_user = create_user
      @request.session[:user] = @second_user
      delete :destroy, :id => @user.login
    end
    should "not destroy the record" do
      assert @user.reload
    end
    should_redirect_to("the first user's path") {user_path(@user)}
    should_set_the_flash_to /have permission/
  end
  context "on GET to :show" do
    setup do
      assert @user = create_user
      get :show, :id => @user.login
    end
    should_assign_to :user
    should_not_set_the_flash
    should_render_template :show
    should_respond_with :success
  end
end

