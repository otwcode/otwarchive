class HelpController < ApplicationController
  HELP_ACTIONS = %i[
    first_login
    preferences_locale
    skins_basics
    skins_creating
    skins_parents
    symbols_key
    tags_fandoms
    tags_ratings
    tags_warnings
  ]

  HELP_REDIRECTS = Hash[
    HELP_ACTIONS.map {|action| [action, "/help/#{action.to_s.gsub('_', '-')}.html"]}
  ].merge({
    first_login: "/first_login_help",
  })

  before_action :users_only, only: [:first_login]
  layout proc { |controller| controller.request.xhr? ? false : "application" } # rubocop:disable Lint/AmbiguousBlockAssociation

  HELP_ACTIONS.each do |action|
    define_method(action) { }
  end
end
