class HelpController < ApplicationController
  HELP_ACTIONS = %i[
    choosing_series
    first_login
    languages_help
    parent_works_help
    preferences_locale
    recipients
    skins_basics
    skins_creating
    skins_parents
    symbols_key
    tags_fandoms
    tags_ratings
    tags_warnings
    translation_link
  ].freeze

  HELP_REDIRECTS = HELP_ACTIONS
    .index_with { |action| "/help/#{action.to_s.gsub('_', '-')}.html" }
    .merge({
             first_login: "/first_login_help"
           }).freeze

  before_action :users_only, only: [:first_login]
  layout proc { |controller| controller.request.xhr? ? false : "application" } # rubocop:disable Lint/AmbiguousBlockAssociation

  HELP_ACTIONS.each do |action|
    define_method(action) do
      # Intentionally empty block for help actions
    end
  end
end
