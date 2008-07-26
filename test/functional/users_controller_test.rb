require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  context "UsersController" do
    context "on Get to :new" do
      setup do
        get :new, :locale => 'en'
      end
      should_assign_to :user
      should_render_template :new
      should_render_a_form
      should_not_set_the_flash
      should_respond_with :success
    end
    context "on POST to :create with password" do
      setup do
        @login = String.random
        password = String.random
        put :create, :locale => 'en', :user=>{"age_over_13" => "1",
                                              "terms_of_service" => "1",
                                              "login" => @login,
                                              "identity_url"=>"",
                                              "email" => random_email,
                                              "password" => password,
                                              "password_confirmation" => password}
      end
      should_assign_to :user
      should_render_template :_confirmation
      should_set_the_flash_to /during testing you can activate via/
      should "create the user" do
        assert User.find_by_login(@login)
      end
    end
    context "on POST to :create with open id" do
      setup do
        @login = String.random
        password = String.random
        put :create, :locale => 'en', :user=>{"age_over_13" => "1",
                                              "terms_of_service" => "1",
                                              "login" => @login,
                                              "identity_url"=> random_url,
                                              "email" => random_email,
                                              "password" => "",
                                              "password_confirmation" => ""}
      end
      should_assign_to :user
      should_render_template :_confirmation
      should_set_the_flash_to /during testing you can activate via/
      should "create the user" do
        assert User.find_by_login(@login)
      end
    end
    context "on POST to :edit self" do
      setup do
        assert @user = create_user
        assert @request.session[:user] = @user 
        get :edit, :locale => 'en', :id => @user.login
      end      
      should_assign_to :user
      should "assign assign @user to user" do
        assert_equal @user, assigns(:user)
      end
      should_render_a_form
      should_not_set_the_flash
      should_render_template :edit
      should_respond_with :success
      
    end
    context "on POST to :edit someone else" do
      setup do
        assert @user = create_user
        get :edit, :locale => 'en', :id => @user.login
      end      
      should "not display a form" do
         assert_select "form", false           
      end
      should_redirect_to 'user_url(@user)'
      should_set_the_flash_to /not allowed/      
    end
    context "on DELETE of self" do
      setup do
        assert @user = create_user
        assert @request.session[:user] = @user 
        delete :destroy, :locale => 'en', :id => @user.login
      end
      should "destroy the record" do
        assert_raises(ActiveRecord::RecordNotFound) { @user.reload }
      end
      should_redirect_to 'users_url'
    end
    context "on DELETE of someone else" do
      setup do
        assert @user = create_user
        delete :destroy, :locale => 'en', :id => @user.login
      end
      should "not destroy the record" do
        assert @user.reload
      end
      should_redirect_to 'user_url(@user)'
      should_set_the_flash_to /not allowed/      
    end
    context "on GET to :index" do
      setup do
        assert @user = create_user
        get :index, :locale => 'en'
      end
      should_assign_to :users
      should_not_set_the_flash
      should_render_template :index
      should_respond_with :success
    end
    context "on GET to :show" do
      setup do
        assert @user = create_user
        get :show, :locale => 'en', :id => @user.login
      end
      should_assign_to :user
      should_not_set_the_flash
      should_render_template :show
      should_respond_with :success
    end
    context "on PUT to :update self" do
      setup do
        @old_email = random_email
        assert @user = create_user(:email => @old_email)
        @new_email = random_email
        assert @old_email != @new_email
        assert @request.session[:user] = @user 
        put :update, :locale => 'en', :id => @user.login, :user => {"email" => @new_email}
      end      
      should_assign_to :user
      should "assign assign @user to user" do
        assert_equal @user, assigns(:user)
      end
      should "make the change" do
        @user.reload
        assert_equal @new_email, @user.email
      end
      should_set_the_flash_to /success/
      should_redirect_to 'user_url(@user)'      
    end
    context "on PUT to :update someone else" do
      setup do
        @new_about = random_paragraph
        assert @user = create_user
        assert @profile = create_profile
        assert @user.profile = @profile
        put :update, :locale => 'en', :id => @user.login, :user => {"email" => @new_email}
      end      
      should "not make the change" do
        assert_not_equal @new_email, @user.email
      end
      should_redirect_to 'user_url(@user)'
      should_set_the_flash_to /not allowed/      
    end
  end
end

