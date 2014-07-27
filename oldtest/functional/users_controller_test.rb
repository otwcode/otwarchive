require 'test_helper'

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

  context "when trying to create an account" do
    context "without an invitation" do
      setup do
        get :new
      end
      should_redirect_to("the login page") {login_url}
      should_set_the_flash_to /Account creation is suspended/
    end
    context "with an invitation" do
      setup do
        @invitation = create_invitation
        assert @invitation.save
      end
      context "and loading the signup page" do
        setup do 
          get :new, :invitation_token => @invitation.token
        end        
        should_respond_with :success
        should "display a form" do
          assert_select "form", true
        end
        should_render_template :new
      end
      context "that has already been used" do
        setup do
          @test_email = random_email
          @test_password = random_password
          post :create, :user => {:invitation_token => @invitation.token, :email => @test_email, :login => String.random,
                        :password => @test_password, :password_confirmation => @test_password, :age_over_13 => "1", :terms_of_service => "1"}
          get :new, :invitation_token => @invitation.token
        end
        should_redirect_to("the login page") {login_url}
        should_set_the_flash_to /already been used/
        context "but then purged" do
          setup do
            User.find_by_email(@test_email).destroy
            get :new, :invitation_token => @invitation.token
          end
          should_respond_with :success
          should "display a form" do
            assert_select "form", true
          end
          should_render_template :new
        end
      end
      context "after submitting valid data" do
        setup do
          @test_email = random_email
          @test_login = String.random
          @test_password = random_password
          post :create, :user => {:invitation_token => @invitation.token, :email => @test_email, :login => @test_login, 
                            :password => @test_password, :password_confirmation => @test_password, :age_over_13 => "1", :terms_of_service => "1"}
          @user = User.find_by_email(@test_email)
        end
        should_assign_to :user
        should "create a valid user that is not activated" do
          assert @user.valid?
          assert !@user.activated_at
        end
        should "mark the invitation as redeemed" do
          @invitation.reload
          assert @invitation.redeemed_at
        end
        should "set the invitation on the user" do
          assert @user.invitation == @invitation
        end 
        should_render_template :confirmation
        context "and then activating" do
          setup do
            @activation_code = @user.activation_code
            get :activate, :id => @activation_code
            @user.reload
          end
          should_assign_to :user
          should_set_the_flash_to /Signup complete/
          should "activate the user" do
            assert @user.activated_at
            assert @user.activation_code.nil?
          end
          should_redirect_to("the user's page") {user_path(@user)}
        end 
      end
    end
  end
  
  context "when trying to activate" do
    context "without a valid activation code" do
      setup do 
        get :activate
      end
      should_set_the_flash_to /activation key is missing/
      should_redirect_to("the home page") {root_path}
    end
  end

  context "when activating a user account with an external author attached to the invitation" do
    setup do
      @external_author = create_external_author
      @invitation = create_invitation(:external_author => @external_author, :invitee_email => @external_author.email)
      @test_email = random_email
      @test_login = String.random
      @test_password = random_password
      post :create, :user => {:invitation_token => @invitation.token, :email => @test_email, :login => @test_login, 
                        :password => @test_password, :password_confirmation => @test_password, :age_over_13 => "1", :terms_of_service => "1"}
      @user = User.find_by_email(@test_email)
      @activation_code = @user.activation_code
      get :activate, :id => @activation_code
      @external_author.reload
      @user.reload
    end
    should_set_the_flash_to /found some stories already uploaded/
    should "assign the external author to the new user" do      
      assert @external_author.user == @user
    end
  end

  context "when activating a user account where there is an external author with the same email address" do
    setup do
      @test_email = random_email
      @invitation = create_invitation
      @external_author = create_external_author(:email => @test_email)
      @test_login = String.random
      @test_password = random_password
      post :create, :user => {:invitation_token => @invitation.token, :email => @test_email, :login => @test_login, 
                        :password => @test_password, :password_confirmation => @test_password, :age_over_13 => "1", :terms_of_service => "1"}
      @user = User.find_by_email(@test_email)
      @activation_code = @user.activation_code
      get :activate, :id => @activation_code
      @external_author.reload
      @user.reload
    end
    should_set_the_flash_to /found some stories already uploaded/
    should "assign the external author to the new user" do      
      assert @external_author.user == @user
    end
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
  
  context "on POST to :end_first_login" do
    setup do
      assert @user = create_user
      assert @request.session[:user] = @user
      get :show, :id => @user.login
    end
    
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

