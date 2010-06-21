require 'test_helper'

class AuthenticationTest < ActionController::IntegrationTest
  def setup
    Tolk::ApplicationController.authenticator = proc do
      authenticate_or_request_with_http_basic {|user_name, password| user_name == 'lifo' && password == 'pass' }
    end
  end

  def teardown
    Tolk::ApplicationController.authenticator = nil
  end

  test "failed authentication" do
    get '/tolk'
    assert_response 401
  end

  test "successful authentication" do
    get '/tolk', nil, 'HTTP_AUTHORIZATION' => encode_credentials('lifo', 'pass')
    assert_response :success
  end

  protected

  def encode_credentials(username, password)
    "Basic #{ActiveSupport::Base64.encode64("#{username}:#{password}")}"
  end
end
