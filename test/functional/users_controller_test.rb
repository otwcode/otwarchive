require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
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
  context "on POST to :create invalid" do
    setup do
      get :new, :locale => 'en'
      form = select_form "new_user"

      form.user.age_over_13.uncheck
      form.user.terms_of_service.uncheck
      form.user.login = String.random + " " + String.random
      form.user.email = String.random
      form.user.password = String.random
      form.user.password_confirmation = String.random
      form.cancel_create_account=nil

      assert form.submit
    end
    should_render_template :new
    should "have error message" do
     assert_tag :div, :content => /Oops/, :attributes => { :id => 'errorExplanationNone' }
    end
    should "have age 13 message" do
     assert_tag :div, :content => /Age over 13/, :attributes => { :id => 'errorExplanationNone' }
    end
    should "have tos message" do
     assert_tag :div, :content => /Terms of service/, :attributes => { :id => 'errorExplanationNone' }
    end
    should "have email message" do
     assert_tag :div, :content => /valid/, :attributes => { :id => 'errorExplanationNone' }
    end
    should "have password confirmation message" do
     assert_tag :div, :content => /passwords don't match/, :attributes => { :id => 'errorExplanationNone' }
    end
    should "have login message" do
     assert_tag :div, :content => /Login.*underscore/, :attributes => { :id => 'errorExplanationNone' }
    end
  end
  context "on POST to :create with password" do
    setup do
      @login = String.random
      password = String.random
      get :new, :locale => 'en'
      form = select_form "new_user"

      form.user.age_over_13.check
      form.user.terms_of_service.check
      form.user.login = @login
      form.user.email = random_email
      form.user.password = password
      form.user.password_confirmation = password
      form.cancel_create_account=nil

      assert form.submit
    end
    should_assign_to :user
    should_render_template :_confirmation
    should "create the user" do
      assert User.find_by_login(@login)
    end
  end
  context "on POST to :create cancelled" do
    setup do
      @login = String.random
      password = String.random
      get :new, :locale => 'en'
      form = select_form "new_user"

      form.user.age_over_13.check
      form.user.terms_of_service.check
      form.user.login = @login
      form.user.email = random_email
      form.user.password = password
      form.user.password_confirmation = password
      form.cancel_create_account='Cancel'
      form.commit=nil

      assert form.submit
    end
    should_redirect_to('the root path') { root_path }
    should "not create the user" do
      assert_nil User.find_by_login(@login)
    end
  end
  context "on POST to :create with open id" do
    setup do
      @login = String.random
      @url = random_url
      get :new, :locale => 'en', :use_openid => true
      form = select_form "new_user"

      form.user.age_over_13.check
      form.user.terms_of_service.check
      form.user.login = @login
      form.user.email = random_email
      form.user.identity_url = @url
      form.cancel_create_account=nil

      assert form.submit
    end
    should_assign_to :user
    should_render_template :_confirmation
    should "create the user" do
      assert User.find_by_login(@login)
    end
    context "that was previously used" do
      setup do
        get :new, :locale => 'en', :use_openid => true
        form = select_form "new_user"

        form.user.age_over_13.check
        form.user.terms_of_service.check
        form.user.login = String.random
        form.user.email = random_email
        form.user.identity_url = @url
        form.cancel_create_account=nil

        assert form.submit
      end
      should "have duplicate message" do
         assert_tag :div, :content => /already being used/, :attributes => { :id => 'errorExplanationNone' }
      end
      should_render_template :new
    end
    context "that is semantically equivalent to one previously used" do
      setup do
        get :new, :locale => 'en', :use_openid => true
        form = select_form "new_user"

        form.user.age_over_13.check
        form.user.terms_of_service.check
        form.user.login = String.random
        form.user.email = random_email + '/'
        form.user.identity_url = @url
        form.cancel_create_account=nil

        assert form.submit
      end
      should "have duplicate message" do
         assert_tag :div, :content => /already being used/, :attributes => { :id => 'errorExplanationNone' }
      end
      should_render_template :new
    end
  end


  context "on POST to :edit someone else" do
    setup do
      assert @user = create_user
      assert @second_user = create_user
      @request.session[:user] = @second_user
      get :edit, :locale => 'en', :id => @user.login
    end
    should "not display a form" do
       assert_select "form", false
    end
    should_redirect_to("the second user's path") {user_path(@second_user)}
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
      put :update, :locale => 'en', :id => @user.login, :user => {"email" => @new_email}
    end
    should "not make the change" do
      assert_not_equal @new_email, @user.email
    end
    should_redirect_to("the second user's path") {user_path(@second_user)}
    should_set_the_flash_to /have permission/
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
  # put to update self tests in profile_controller_test

  context "on DELETE of self" do
    setup do
      assert @user = create_user
      assert @request.session[:user] = @user
      delete :destroy, :locale => 'en', :id => @user.login
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
      delete :destroy, :locale => 'en', :id => @user.login
    end
    should "not destroy the record" do
      assert @user.reload
    end
    should_redirect_to("the second user's path") {user_path(@second_user)}
    should_set_the_flash_to /have permission/
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
end

