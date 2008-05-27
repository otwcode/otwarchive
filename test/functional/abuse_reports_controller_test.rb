require File.dirname(__FILE__) + '/../test_helper'

class AbuseReportsControllerTest < ActionController::TestCase

  # create  /:locale/abuse/fix  (named path: abuse_reports)
  # if @abuse_report.save deliver_abuse_report
  def test_abuse_reports_path
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    url = random_url(ArchiveConfig.APP_URL)
    assert_difference('AbuseReport.count') do
      post :create, :locale => 'en', :abuse_report => 
       { :email => random_email,
         :url => url,
         :comment => random_phrase }
    end
    assert_equal(1, ActionMailer::Base.deliveries.length)
    assert flash.has_key?(:notice)
    assert_redirected_to url
  end
  # if ! @abuse_report.save render new
  def test_abuse_reports_path_error
    bad_url = random_url
    post :create, :locale => 'en', :abuse_report => 
       { :email => random_email,
         :url => bad_url,
         :comment => random_phrase }
    assert !flash.has_key?(:notice)
    assert_template "abuse_reports/new"
  end

  # new  /:locale/abuse  (named path: new_abuse_report)
  # if User.current_user
  def test_new_abuse_report_path_user
    user = create_user
    @request.session[:user] = user 
    get :new, :locale => 'en'
    assert_response :success
    assert_equal user.email, assigns["abuse_report"][:email]
  end
  # if ! User.current_user
  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
    assert_equal '',  assigns["abuse_report"][:email]
  end

end
