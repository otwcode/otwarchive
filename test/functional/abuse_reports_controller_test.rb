require File.dirname(__FILE__) + '/../test_helper'

class AbuseReportsControllerTest < ActionController::TestCase

  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
  end

  def test_should_deliver_abuse_report
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    url_reported = random_url(ArchiveConfig.APP_URL)

    assert_difference('AbuseReport.count') do
      post :create, :locale => 'en', :abuse_report => 
       { :email => random_email,
         :url => url_reported,
         :comment => random_phrase }
    end

    assert_equal(1, ActionMailer::Base.deliveries.length)
    assert flash.has_key?(:notice)
    assert_redirected_to url_reported
  end

  def test_should_not_deliver_abuse_report
    bad_url = random_url
    post :create, :locale => 'en', :abuse_report => 
       { :email => random_email,
         :url => bad_url,
         :comment => random_phrase }
    assert !flash.has_key?(:notice)
    assert_template "abuse_reports/new"
  end

end
