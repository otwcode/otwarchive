class Api::V1::BaseController < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
end
