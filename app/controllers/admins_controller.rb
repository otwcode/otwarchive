class AdminsController < ApplicationController
  before_filter :admin_only
  
end
