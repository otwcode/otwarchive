require File.dirname(__FILE__) + '/../test_helper'

class FeedbacksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:feedbacks)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_feedback
    assert_difference('Feedback.count') do
      post :create, :feedback => { }
    end

    assert_redirected_to feedback_path(assigns(:feedback))
  end

  def test_should_show_feedback
    get :show, :id => feedbacks(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => feedbacks(:one).id
    assert_response :success
  end

  def test_should_update_feedback
    put :update, :id => feedbacks(:one).id, :feedback => { }
    assert_redirected_to feedback_path(assigns(:feedback))
  end

  def test_should_destroy_feedback
    assert_difference('Feedback.count', -1) do
      delete :destroy, :id => feedbacks(:one).id
    end

    assert_redirected_to feedbacks_path
  end
end
