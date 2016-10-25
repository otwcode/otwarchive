require "spec_helper"
require "webmock"
require "api/api_helper"

describe "API Authorization" do
  include ApiHelper
  end_points = %w(api/v1/works api/v1/bookmarks)

  describe "API POST with invalid request" do
    it "should return 401 Unauthorized if no token is supplied" do
      end_points.each do |url|
        post url
        assert_equal 401, response.status
      end
    end

    it "should return 403 Forbidden if the specified user isn't an archivist" do
      end_points.each do |url|
        post url,
             { archivist: "mr_nobody" }.to_json,
             valid_headers
        assert_equal 403, response.status
      end
    end
  end
end
