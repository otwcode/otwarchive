class Api::V1::WorksController < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
end
