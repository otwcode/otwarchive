class HelpController < ApplicationController
  before_action :users_only, only: [:first_login]
  layout Proc.new { |controller| controller.request.xhr? ? false : "application" }

  def first_login
  end

  def preferences_locale
  end
end
