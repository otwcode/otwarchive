class Admin::BaseController < ApplicationController
  before_action :admin_only

  def pundit_user
    current_admin
  end

end
