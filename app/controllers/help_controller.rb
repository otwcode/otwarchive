class HelpController < ApplicationController
  HELP_ACTIONS = %i[
    choosing_series
    first_login
    languages_help
    parent_works_help
    preferences_collection
    preferences_comment
    preferences_display
    preferences_locale
    preferences_misc
    preferences_privacy
    preferences_work_title_format
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
             first_login: "/first_login_help",
             preferences_collection: "/help/collection-preferences.html",
             preferences_comment: "/help/comment-preferences.html",
             preferences_display: "/help/display-preferences.html",
             preferences_misc: "/help/misc-preferences.html",
             preferences_privacy: "/help/privacy-preferences.html",
             preferences_work_title_format: "/help/work_title_format.html"
           }).freeze

  before_action :users_only, only: [:first_login]
  layout proc { |controller| controller.request.xhr? ? false : "application" } # rubocop:disable Lint/AmbiguousBlockAssociation

  HELP_ACTIONS.each do |action|
    define_method(action) do
      # Intentionally empty block for help actions
    end
  end
end
