class Api::V1::Bookmarks < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
end
