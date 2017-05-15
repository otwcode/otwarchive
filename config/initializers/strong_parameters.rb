ActiveRecord::Base.class_eval do
  include ActiveModel::ForbiddenAttributesProtection
end
