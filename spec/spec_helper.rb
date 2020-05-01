ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'simplecov'
SimpleCov.command_name "rspec-" + (ENV['TEST_RUN'] || '')
if ENV["CI"] == "true" && ENV["TRAVIS"] == "true"
  # Only on Travis...
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'rspec/rails'
require 'factory_bot'
require 'database_cleaner'
require 'email_spec'

DatabaseCleaner.start
DatabaseCleaner.clean

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

FactoryBot.find_definitions
FactoryBot.definition_file_paths = %w(factories)

RSpec.configure do |config|
  config.mock_with :rspec

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.include FactoryBot::Syntax::Methods
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Capybara::DSL
  config.include TaskExampleGroup, type: :task

  config.before :suite do
    Rails.application.load_tasks
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean
    Indexer.all.map(&:prepare_for_testing)
  end

  config.before :each do
    DatabaseCleaner.start
    User.current_user = nil
    clean_the_database

    # Assume all spam checks pass by default.
    allow(Akismetor).to receive(:spam?).and_return(false)
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.after :suite do
    DatabaseCleaner.clean_with :truncation
    Indexer.all.map(&:delete_index)
  end

  config.before :each, bookmark_search: true do
    BookmarkIndexer.prepare_for_testing
  end

  config.after :each, bookmark_search: true do
    BookmarkIndexer.delete_index
  end

  config.before :each, pseud_search: true do
    PseudIndexer.prepare_for_testing
  end

  config.after :each, pseud_search: true do
    PseudIndexer.delete_index
  end

  config.before :each, tag_search: true do
    TagIndexer.prepare_for_testing
  end

  config.after :each, tag_search: true do
    TagIndexer.delete_index
  end

  config.before :each, work_search: true do
    WorkIndexer.prepare_for_testing
  end

  config.after :each, work_search: true do
    WorkIndexer.delete_index
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # For email veracity checks
  BAD_EMAILS = ['Abc.example.com', 'A@b@c@example.com', 'a\"b(c)d,e:f;g<h>i[j\k]l@example.com', 'this is"not\allowed@example.com', 'this\ still\"not/\/\allowed@example.com', 'nodomain', 'foo@oops'].freeze
  # For email format checks
  BADLY_FORMATTED_EMAILS = ['ast*risk@example.com', 'asterisk@ex*ample.com'].freeze
  INVALID_URLS = ['no_scheme.com', 'ftp://ftp.address.com', 'http://www.b@d!35.com', 'https://www.b@d!35.com', 'http://b@d!35.com', 'https://www.b@d!35.com'].freeze
  VALID_URLS = ['http://rocksalt-recs.livejournal.com/196316.html', 'https://rocksalt-recs.livejournal.com/196316.html'].freeze
  INACTIVE_URLS = ['https://www.iaminactive.com', 'http://www.iaminactive.com', 'https://iaminactive.com', 'http://iaminactive.com'].freeze

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, type: :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
  config.define_derived_metadata(file_path: %r{/spec/lib/tasks/}) do |metadata|
    metadata[:type] = :task
  end

  # Set default formatter to print out the description of each test as it runs
  config.color = true
  config.formatter = :documentation

  config.file_fixture_path = "spec/support/fixtures"
end

def clean_the_database
  # Now clear memcached
  Rails.cache.clear

  # Clear Redis
  REDIS_AUTOCOMPLETE.flushall
  REDIS_GENERAL.flushall
  REDIS_HITS.flushall
  REDIS_KUDOS.flushall
  REDIS_RESQUE.flushall
  REDIS_ROLLOUT.flushall
end

def run_all_indexing_jobs
  %w[main background stats].each do |reindex_type|
    ScheduledReindexJob.perform reindex_type
  end
  Indexer.all.map(&:refresh_index)
end

# Suspend resque workers for the duration of the block, then resume after the
# contents of the block have run. Simulates what happens when there's a lot of
# jobs already in the queue, so there's a long delay between jobs being
# enqueued and jobs being run.
def suspend_resque_workers
  # Set up an array to keep track of delayed actions.
  queue = []

  # Override the default Resque.enqueue_to behavior.
  #
  # The first argument is which queue the job is supposed to be added to, but
  # it doesn't matter for our purposes, so we ignore it.
  allow(Resque).to receive(:enqueue_to) do |_, klass, *args|
    queue << [klass, args]
  end

  # Run the code inside the block.
  yield

  # Empty out the queue and perform all of the operations.
  while queue.any?
    klass, args = queue.shift
    klass.perform(*args)
  end

  # Resume the original Resque.enqueue_to behavior.
  allow(Resque).to receive(:enqueue_to).and_call_original
end
