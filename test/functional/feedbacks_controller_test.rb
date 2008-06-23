require File.dirname(__FILE__) + '/../test_helper'

class FeedbacksControllerTest < ActionController::TestCase

  # create  /:locale/feedback/fix  (named path: feedbacks)
  # if @feedback.save deliver_feedback
  def test_feedbacks_path
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    assert_difference('Feedback.count') do
      post :create, :locale => 'en', :feedback => 
       { :comment => random_phrase }
    end
    assert_equal(1, ActionMailer::Base.deliveries.length)
    assert flash.has_key?(:notice)
    assert_redirected_to (:controller => "session", :action => "new")
  end
  # if ! @feedback.save render new
  def test_feedbacks_path_error
    
    post :create, :locale => 'en', :feedback => 
       { :comment => "" }
    assert !flash.has_key?(:notice)
    assert_template "feedbacks/new"
  end

 
end
