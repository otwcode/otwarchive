# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

# This file has been edited by hand :(
require 'simplecov'
require 'coveralls'
require 'cucumber/timecop'
require 'capybara/poltergeist'
SimpleCov.command_name "features-" + (ENV['TEST_RUN'] || 'local')
Coveralls.wear_merged!('rails') unless ENV['TEST_LOCAL']
require 'cucumber/rails'
require 'email_spec'
require 'email_spec/cucumber'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

# Produce a screen shot for each failure
require 'capybara-screenshot/cucumber'

# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#

ActionController::Base.allow_rescue = false

# Config options for Capybara, including increased timeout to minimise failures on CI servers
# ring-fence with if ENV['CI'] if this becomes a problem locally
Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = false
  config.default_max_wait_time = 25
end

@javascript = false
Before '@javascript' do
  @javascript = true
end

Before do
  settings = AdminSetting.new(invite_from_queue_enabled: ArchiveConfig.INVITE_FROM_QUEUE_ENABLED,
          invite_from_queue_number: ArchiveConfig.INVITE_FROM_QUEUE_NUMBER,
          invite_from_queue_frequency: ArchiveConfig.INVITE_FROM_QUEUE_FREQUENCY,
          account_creation_enabled: ArchiveConfig.ACCOUNT_CREATION_ENABLED,
          days_to_purge_unactivated: ArchiveConfig.DAYS_TO_PURGE_UNACTIVATED)
  settings.save(validate: false)

  language = Language.find_or_create_by(short: 'en', name: 'English')
  Locale.set_base_locale(iso: "en", name: "English (US)", language_id: language.id)

  response = $elasticsearch.perform_request("GET", "/")
  if response.status == 200
    version = response.body["version"]
  else
    raise response.inspect
  end

  @es_version = version["number"]

  ['work', 'bookmark', 'pseud', 'tag'].each do |klass|
    index_name = "ao3_test_#{klass.to_s.downcase}s"

    if $new_elasticsearch.indices.exists? index: index_name
      $new_elasticsearch.indices.delete index: index_name
    end

    indexer_class = "#{klass.capitalize}Indexer".constantize

    indexer_class.create_index

    indexer = indexer_class.new(klass.capitalize.constantize.all.pluck(:id))
    indexer.index_documents rescue nil

    if klass == 'bookmark'
      bookmark_indexers = {
        BookmarkedExternalWorkIndexer => ExternalWork,
        BookmarkedSeriesIndexer => Series,
        BookmarkedWorkIndexer => Work
      }

      bookmark_indexers.each do |indexer, bookmarkable|
        indexer.new(bookmarkable.all.pluck(:id)).index_documents if bookmarkable.any?
      end
    end

    $new_elasticsearch.indices.refresh index: "ao3_test_#{klass}s"
  end
end

Before '@disable_caching' do
  ActionController::Base.perform_caching = false
end

After '@disable_caching' do
  ActionController::Base.perform_caching = true
end

# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :transaction

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist
