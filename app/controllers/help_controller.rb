class HelpController < ApplicationController
  before_action :users_only, only: [:first_login]
  layout false

  def first_login
  end

  def preferences_locale
  end
end
