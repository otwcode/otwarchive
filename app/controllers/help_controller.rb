class HelpController < ApplicationController
  before_action :users_only, only: [:first_login]
  layout proc { |controller| controller.request.xhr? ? false : "application" } # rubocop:disable Lint/AmbiguousBlockAssociation

  def first_login
  end

  def preferences_locale
  end

  def skins_basics
  end

  def skins_creating
  end

  def skins_parents
  end

  def tags_fandoms
  end

  def tags_ratings
  end

  def tags_warnings
  end
end
