class HelpController < ApplicationController
  before_action :users_only, only: [:first_login]
  layout proc { |controller| controller.request.xhr? ? false : "application" } # rubocop:disable Lint/AmbiguousBlockAssociation

  def first_login
  end

  def preferences_locale
  end

  def moderated_commenting
  end

  def restricted_commenting
  end

  def restricted_works
  end

  def work_skins
  end
end
