require File.dirname(__FILE__) + '/../test_helper'

class AbuseReportsControllerTest < ActionController::TestCase

  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
  end

  def test_should_create_abuse_report
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    assert_difference('AbuseReport.count') do
      post :create, :locale => 'en', :abuse_report => 
       { :email => 'test_create@example.com',
         :url => 'http://www.test.com/en/works/2',
         :comment => 'I hate work 2' }
    end

    assert_equal(1, ActionMailer::Base.deliveries.length)
    assert flash.has_key?(:notice)
    assert_redirected_to 'http://www.test.com/en/works/2'
  end

  def test_didnt_save   # a missing url will prevent save
    post :create, :locale => 'en', :abuse_report => 
       { :email => 'test_create@example.com',
         :url => '',
         :comment => 'I hate work 2' }
    assert !flash.has_key?(:notice)
    assert_template "abuse_reports/new"
    assert_response :success
  end

end
