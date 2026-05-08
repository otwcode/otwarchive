class HelpController < ApplicationController
  HELP_ACTIONS = %i[
    first_login
    html
    preferences_collection
    preferences_comment
    preferences_display
    preferences_locale
    preferences_misc
    preferences_privacy
    preferences_work_title_format
    rte
    skins_basics
    skins_creating
    skins_parents
    symbols_key
    tags_fandoms
    tags_ratings
    tags_warnings
    works_languages
    works_parents
    works_recipients
    works_series
    works_translation_link
  ].freeze

  before_action :users_only, only: [:first_login]
  layout proc { |controller| controller.request.xhr? ? false : "application" } # rubocop:disable Lint/AmbiguousBlockAssociation

  HELP_ACTIONS.each do |action|
    define_method(action) do
      # Intentionally empty block for help actions
    end
  end
end
