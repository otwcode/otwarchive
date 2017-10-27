class Users::SessionsController < Devise::SessionsController
  before_action :admin_logout_required, except: :destroy
  skip_after_action :store_location, raise: false
end
