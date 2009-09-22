require File.dirname(__FILE__) + '/../test_helper'


class ExternalAuthorsControllerTest < ActionController::TestCase

  # Test create  POST  /:locale/users/:user_id/external_authors
  def test_should_create_external_author
    user = create_user
    @request.session[:user] = user
    assert_difference('ExternalAuthor.count') do
      post :create, :user_id => user.login, 
                    :external_author => { :email => 'foo@bar.com' }
    end
    assert_redirected_to user_external_authors_path(user)
  end
  
  # Test destroy  DELETE /:locale/users/:user_id/external_authors/:id
  def test_should_destroy_external_author
    user = create_user
    external_author = create_external_author(:user => user)
    user = User.find(user.id)
    @request.session[:user] = user
    assert_difference('ExternalAuthor.count', -1) do
      delete :destroy, 
      :user_id => user.login, 
      :id => ExternalAuthor.find(external_author.id)
    end

    assert_redirected_to user_external_authors_path(user)
  end

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
    
end
