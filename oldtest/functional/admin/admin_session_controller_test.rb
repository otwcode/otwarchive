require File.dirname(__FILE__) + '/../../test_helper'

class Admin::AdminSessionControllerTest < ActionController::TestCase
  # TODO test   before_filter :user_logout_required

  # create  POST  /:locale/admin/session
  def test_create_admin_session
    post :create, :locale => 'en'
    assert_response :success
    # TODO put actual authentication logic here
  end
  # destroy  DELETE /:locale/admin/session
  def test_destroy_admin_session_default
    delete :destroy, :locale => 'en'
    assert flash[:notice] =~ /logged out/
    # assert_redirected_to new_admin_session_path
  end
  def test_destroy_admin_session_back
    @request.env['HTTP_REFERER'] = '/en/session/new'
    delete :destroy, :locale => 'en'
    assert flash[:notice] =~ /logged out/
    # assert_redirected_to new_admin_session_path
  end
  # edit  GET  /:locale/admin_session/edit  (named path: edit_admin_session)
  def test_edit_admin_session
    # FIXME route exists but no action in controller, remove route?
    #get :edit, :locale => 'en'
  end
  # new  GET  /:locale/admin/session/new  (named path: new_admin_session)
  def test_new_admin_session
    get :new, :locale => 'en'
    assert_response :success
  end
  # show  GET  /:locale/admin_session  (named path: admin_session)
  def test_admin_session
    # FIXME route exists but no action in controller, remove route?
    # get :show, :locale => 'en'
  end
  # update  PUT  /:locale/admin_session
  def test_admin_session
    # FIXME route exists but no action in controller, remove route?
    # put :update, :locale => 'en'
  end
end
