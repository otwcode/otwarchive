require 'test_helper'

class PseudsControllerTest < ActionController::TestCase

# TODO error checking

  # Test create  POST  /:locale/users/:user_id/pseuds
  def test_should_create_pseud
    user = create_user
    @request.session[:user] = user
    assert_difference('Pseud.count') do
      post :create, :user_id => user.login, 
                    :pseud => { :name => 'New Pseud' }
    end

    assert_redirected_to user_pseud_path(user, assigns(:pseud))
  end
  # Test destroy  DELETE /:locale/users/:user_id/pseuds/:id
  def test_should_destroy_pseud
    user = create_user
    pseud = create_pseud(:user => user)
    user = User.find(user.id)
    @request.session[:user] = user
    assert_difference('Pseud.count', -1) do
      delete :destroy, 
      :user_id => user.login, 
      :id => Pseud.find(pseud.id).name
    end

    assert_redirected_to user_pseuds_path(user)
  end
  # Test edit  GET  /:locale/users/:user_id/pseuds/:id/edit  (named path: edit_user_pseud)
  def test_should_get_edit
    user = create_user
    @request.session[:user] = user
    default = user.default_pseud
    get :edit, :user_id => user.login,
               :id => default.name
    assert_response :success
  end
  # Test index  GET  /:locale/users/:user_id/pseuds  (named path: user_pseuds)
  def test_user_pseuds_path
    user = create_user
    get :index, :user_id => user.login
    assert_response :success
    assert_not_nil assigns(:pseuds)
  end
  # Test new  GET  /:locale/users/:user_id/pseuds/new  (named path: new_user_pseud)
  def test_new_user_pseud_path
    user = create_user
    @request.session[:user] = user
    get :new, :user_id => user.login
    assert_response :success
  end
  # Test show  GET  /:locale/users/:user_id/pseuds/:id  (named path: user_pseud)
  def test_user_pseud_path
    user = create_user
    default = user.default_pseud
    get :show, :user_id => user.login, 
               :id => default.name
    assert_response :success
  end
  # Test update  PUT  /:locale/users/:user_id/pseuds/:id
  # We don't allow you to change the name of the fallback pseud, so this tests a new pseud
  def test_update_pseud
    user = create_user
    pseud = create_pseud(:user => user, :name => 'Non Fallback Pseud')
    @request.session[:user] = user
    put :update, :user_id => user.login, 
                 :id => pseud.name, 
                 :pseud => { :name => 'Changed Pseud' }
    assert_redirected_to user_pseud_path(user, assigns(:pseud))
  end

end
