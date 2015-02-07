module Api
  module V1
    class BaseController < ApplicationController
      before_filter :restrict_access

      private

      def restrict_access
        unless ApiKey.exists?(access_token: params[:token])
          authenticate_or_request_with_http_token do |token, _options|
            ApiKey.exists?(access_token: token)
          end
        end
      end
    end
  end
end
