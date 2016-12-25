class Admin::UserCreationsController < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
end
