module Api
  # Version the API explicitly in the URL to allow different versions with breaking changes to co-exist if necessary.
  # The roll over to the next number should happen when code written against the old version will not work
  # with the new version.
  module V1
    class BaseController < ApplicationController
      before_filter :restrict_access

      private

      # Look for a token in the Authorization header only and check that the token isn't currently banned
      def restrict_access
        authenticate_or_request_with_http_token do |token, _|
          ApiKey.exists?(access_token: token) && !ApiKey.find_by_access_token(token).banned?
        end
      end
    end
  end
end
