require 'spec_helper'
require 'webmock'

describe "API ImportController" do

  # Let the test get at external sites, but stub out anything containing "foo"
  WebMock.allow_net_connect!
  WebMock.stub_request(:any, /foo/).
    to_return(status: 200, body: "stubbed response", headers: {})
  WebMock.stub_request(:any, /bar/).
    to_return(status: 404, headers: {})

  # set up a valid token and some headers
  def valid_headers
    api = ApiKey.first_or_create!(name: "Test", access_token: "testabc")
    {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Token.encode_credentials(api.access_token),
      "HTTP_ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json"
    }
  end


  describe "API import with invalid request" do

    it "should return 401 Unauthorized if no token is supplied" do
      post "/api/v1/import"
      assert_equal 401, response.status
    end

    it "should return 403 Forbidden if the specified user isn't an archivist" do
      post "/api/v1/import",
           { archivist: "mr_nobody" }.to_json,
           valid_headers
      assert_equal 403, response.status
    end
  end

  # Override is_archivist so all users are archivists from this point on
  class User < ActiveRecord::Base
    def is_archivist?
      true
    end
  end

  describe "API import with a valid archivist" do

    it "should return 201 Created when all stories are created" do
      user = create(:user)
      post "/api/v1/import",
           { archivist: user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://foo"] }]
           }.to_json,
           valid_headers
      assert_equal 201, response.status
    end

    it "should return 422 Unprocessable Entity when no stories are created" do
      user = create(:user)
      post "/api/v1/import",
           { archivist: user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://bar"] }]
           }.to_json,
           valid_headers
      assert_equal 422, response.status
    end

    it "should return 207 Multi-Status when only some stories are created" do
      user = create(:user)
      post "/api/v1/import",
           { archivist: user.login,
             works: [{ external_author_name: "bar",
                       external_author_email: "bar@foo.com",
                       chapter_urls: ["http://foo"] },
                     { external_author_name: "bar2",
                       external_author_email: "bar2@foo.com",
                       chapter_urls: ["http://foo"] }]
           }.to_json,
           valid_headers
      assert_equal 207, response.status
    end

    it "should return 400 Bad Request if no works are specified" do
      user = create(:user)
      post "/api/v1/import",
           { archivist: user.login }.to_json,
           valid_headers
      assert_equal 400, response.status
    end
  end

  WebMock.allow_net_connect!
end
