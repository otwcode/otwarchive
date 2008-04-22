require File.dirname(__FILE__) + '/../test_helper'

class PseudsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :locale => 'en'
    assert_response :success
    assert_not_nil assigns(:pseuds)
  end

  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
  end

  def test_should_create_pseud
    assert_difference('Pseud.count') do
      post :create, :locale => 'en', :pseud => { }
    end

    assert_redirected_to pseud_path(assigns(:pseud))
  end

  def test_should_show_pseud
    get :show, :locale => 'en', :id => pseuds(:default_pseud).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :locale => 'en', :id => pseuds(:default_pseud).id
    assert_response :success
  end

  def test_should_update_pseud
    put :update, :locale => 'en', :id => pseuds(:default_pseud).id, :pseud => { }
    assert_redirected_to pseud_path(assigns(:pseud))
  end

  def test_should_destroy_pseud
    assert_difference('Pseud.count', -1) do
      delete :destroy, :locale => 'en', :id => pseuds(:default_pseud).id
    end

    assert_redirected_to pseuds_path
  end
end
