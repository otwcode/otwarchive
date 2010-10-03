require 'test_helper'

class AdminsControllerTest < ActionController::TestCase
  # create  POST  /:locale/admins
  def test_create_admin_fail
    post :create, :locale => 'en', :admin => {}
    assert_redirected_to '/'
  end
  def test_create_admin
    admin = create_admin
    @request.session[:admin] = admin
    # FIXME route exists, but no action in controller
    # post :create, :locale => 'en', :admin => {}
  end
  # destroy  DELETE /:locale/admins/:id
  def test_destroy_admin_fail
    admin = create_admin
    delete :destroy, :locale => 'en', :id => admin.id
    assert_redirected_to '/'
  end
  def test_destroy_admin
    admin = create_admin
    @request.session[:admin] = admin
    assert_difference('Admin.count', -1) do
      delete :destroy, :locale => 'en', :id => admin.id
    end
    assert_redirected_to admins_path
  end
  # edit  GET  /:locale/admins/:id/edit  (named path: edit_admin)
  def test_edit_admin_path_fail
    admin = create_admin
    get :edit, :locale => 'en', :id => admin.id
    assert_redirected_to '/'
  end
  def test_edit_admin_path
    admin = create_admin
    @request.session[:admin] = admin
    # FIXME route exists, but no action in controller
    # get :edit, :locale => 'en', :id => admin.id
  end
  # index  GET  /:locale/admins  (named path: admins)
  def test_admins_path_fail
    get :index, :locale => 'en'
    assert_redirected_to '/'
  end
  def test_admins_path
    admin = create_admin
    @request.session[:admin] = admin
    get :index, :locale => 'en'
    assert_response :success
    assert_not_nil assigns(:admins)
  end
  # new  GET  /:locale/admins/new  (named path: new_admin)
  def test_new_admin_path_fail
    get :new, :locale => 'en'
    assert_redirected_to '/'
  end
  def test_new_admin_path
    admin = create_admin
    @request.session[:admin] = admin
    # FIXME route exists, but no action in controller
    # get :new, :locale => 'en' 
  end
  # show  GET  /:locale/admins/:id  (named path: admin)
  def test_admin_path_fail
    admin = create_admin
    get :show, :id => admin.id, :locale => 'en'
    assert_redirected_to '/'
    end
# Don't have a page for admins yet
#  def test_admin_path
#    admin = create_admin
#    login_as_admin(:admin)
#    get :show, :locale => 'en', :id => admin.id
#    assert_response :success
#  end
  # update  PUT  /:locale/admins/:id
  def test_update_admin_fail
    admin = create_admin
    put :update, :id => admin.id, :locale => 'en'
    assert_redirected_to '/'
  end
  def test_update_admin
    admin = create_admin
    @request.session[:admin] = admin
    # FIXME route exists, but no action in controller
#    put :update, :id => admin.id
#    assert_response :success
  end
   
end
