require 'test_helper'


class ExternalAuthorsControllerTest < ActionController::TestCase

  # Test create  POST  /:locale/users/:user_id/external_authors
  # def test_should_create_external_author
  #   user = create_user
  #   @request.session[:user] = user
  #   assert_difference('ExternalAuthor.count') do
  #     post :create, :user_id => user.login, 
  #                   :external_author => { :email => 'foo@bar.com' }
  #   end
  #   assert_redirected_to user_external_authors_path(user)
  # end
  # 
  # # Test destroy  DELETE /:locale/users/:user_id/external_authors/:id
  # def test_should_destroy_external_author
  #   user = create_user
  #   external_author = create_external_author(:user => user)
  #   user = User.find(user.id)
  #   @request.session[:user] = user
  #   assert_difference('ExternalAuthor.count', -1) do
  #     delete :destroy, 
  #     :user_id => user.login, 
  #     :id => ExternalAuthor.find(external_author.id)
  #   end
  # 
  #   assert_redirected_to user_external_authors_path(user)
  # end

  # Test edit  GET  /:locale/users/:user_id/external_authors/:id/edit  (named path: edit_user_external_author)
  def test_should_get_edit
    user = create_user
    external_author = create_external_author(:user => user)
    @request.session[:user] = user

    get :edit, :user_id => user.login,
               :id => external_author.id
    assert_response :success
  end

  # Test index  GET  /:locale/users/:user_id/external_authors  (named path: user_external_authors)
  def test_user_external_authors_path
    user = create_user
    external_author = create_external_author(:user => user)
    @request.session[:user] = user
    get :index, :user_id => user.login
    assert_response :success
    assert_not_nil assigns(:external_authors)
  end
  
  
  # Test update  PUT  /:locale/users/:user_id/external_authors/:id
  # We don't allow you to change the name of the fallback external_author, so this tests a new external_author
  def test_update_external_author
    user = create_user
    external_author = create_external_author(:user => user, :email => 'afsfds@gmail.com')
    @request.session[:user] = user
    put :update, :user_id => user.login, 
                 :id => external_author.id, 
                 :external_author => { :do_not_email => 'true' }
    assert_redirected_to user_external_authors_path(user)
  end

  context "when claiming an external author" do
    context "without a valid invitation" do
      setup do
        get :claim
      end
      should_set_the_flash_to /You need an invitation/
      should_redirect_to("the home page") {root_path}
    end
    context "with a valid invitation" do
      setup do 
        @invitation = create_invitation
        @invitation.save
      end
      context "that has no external author" do
        setup do
          get :claim, :invitation_token => @invitation.token
        end
        should_set_the_flash_to /no stories to claim/
        should_redirect_to("the signup page") {signup_path(@invitation.token)}
      end
      context "with an external author attached" do
        setup do
          @external_author = create_external_author
          @test_work = create_work 
          @test_work.add_default_tags
          creatorship = create_external_creatorship(:external_author_name => @external_author.names.first, :creation => @test_work)
          @test_work.save 
          @invitation.external_author = @external_author
          @invitation.save
          get :claim, :invitation_token => @invitation.token
        end
        should_respond_with :success
        should "display a form" do
          assert_select "form", true
        end
        should_render_template :claim
        context "and completing a claim" do
          context "without being logged in" do
            setup do
              get :complete_claim, :locale => 'en', :invitation_token => @invitation.token        
            end
            should_set_the_flash_to /Please log in/
            should_redirect_to("the login page") {new_session_path}
          end
        end
      end
    end
  end

  context "completing a claim when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user
      
      @external_author = create_external_author
      archivist = create_user(:login => "archivist")
      @test_work = create_work(:authors => [archivist.default_pseud], :chapters => [new_chapter(:authors => [archivist.default_pseud])]) 
      @test_work.add_default_tags
      creatorship = create_external_creatorship(:external_author_name => @external_author.names.first, :creation => @test_work)
      @test_work.save
      @invitation = create_invitation(:external_author => @external_author)
      get :complete_claim, :locale => 'en', :invitation_token => @invitation.token
    end
    should_set_the_flash_to /have added the stories imported under/
    should_redirect_to("the user's external authors page") {user_external_authors_path(@user)}
    should "claim the external author for the user" do
      @user.reload
      @external_author.reload
      assert @user.external_authors.include?(@external_author)
      assert @external_author.user == @user
      assert @user.works.include?(@test_work)
    end
  end
    
end
