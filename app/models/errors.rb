class Errors < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
end
