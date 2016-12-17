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

      # Top-level error handling: returns a 403 forbidden if a valid archivist isn't supplied and a 400
      # if no works are supplied. If there is neither a valid archivist nor valid works, a 400 is returned
      # with both errors as a message
      def batch_errors(archivist, import_items)
        status = :bad_request
        errors = []

        unless archivist && archivist.is_archivist?
          status = :forbidden
          errors << "The 'archivist' field must specify the name of an Archive user with archivist privileges."
        end

        if import_items.nil? || import_items.empty?
          errors << "No items to import were provided."
        elsif import_items.size >= ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST
          errors << "This request contains too many items to import. A maximum of #{ ArchiveConfig.IMPORT_MAX_WORKS_BY_ARCHIVIST } " +
            "items can be imported at one time by an archivist."
        end
        status = :ok if errors.empty?
        [status, errors]
      end
    end
  end
end
