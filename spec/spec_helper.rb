ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'simplecov'
SimpleCov.command_name "rspec-" + (ENV['TEST_RUN'] || '')
if ENV["CI"] == "true"
  # Only on Travis...
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'rspec/rails'
require 'factory_girl'
require 'database_cleaner'
require 'email_spec'

DatabaseCleaner.start

DatabaseCleaner.clean


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

FactoryGirl.find_definitions
FactoryGirl.definition_file_paths = %w(factories)

RSpec.configure do |config|
  config.mock_with :rspec

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.include FactoryGirl::Syntax::Methods
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Capybara::DSL

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean
  end

  config.before :each do
    DatabaseCleaner.start
    User.current_user = nil
    clean_the_database
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.after :suite do
    DatabaseCleaner.clean_with :truncation
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  BAD_EMAILS = ['Abc.example.com','A@b@c@example.com','a\"b(c)d,e:f;g<h>i[j\k]l@example.com','just"not"right@example.com','this is"not\allowed@example.com','this\ still\"not/\/\allowed@example.com', 'nodomain']
  INVALID_URLS = ['no_scheme.com', 'ftp://ftp.address.com','http://www.b@d!35.com','https://www.b@d!35.com','http://b@d!35.com','https://www.b@d!35.com']
  VALID_URLS = ['http://rocksalt-recs.livejournal.com/196316.html','https://rocksalt-recs.livejournal.com/196316.html']
  INACTIVE_URLS = ['https://www.iaminactive.com','http://www.iaminactive.com','https://iaminactive.com','http://iaminactive.com']

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
end

def clean_the_database
  # Now clear memcached
  Rails.cache.clear
  # Now reset redis ...
  REDIS_GENERAL.flushall
  REDIS_KUDOS.flushall
  REDIS_RESQUE.flushall
  REDIS_ROLLOUT.flushall
  REDIS_AUTOCOMPLETE.flushall
  # Finally elastic search
  Work.tire.index.delete
  Work.create_elasticsearch_index

  Bookmark.tire.index.delete
  Bookmark.create_elasticsearch_index

  Tag.tire.index.delete
  Tag.create_elasticsearch_index

  Pseud.tire.index.delete
  Pseud.create_elasticsearch_index
end

def get_message_part (mail, content_type)
  mail.body.parts.find { |p| p.content_type.match content_type }.body.raw_source
end

shared_examples_for "multipart email" do
  it "generates a multipart message (plain text and html)" do
    expect(email.body.parts.length).to eq(2)
    expect(email.body.parts.collect(&:content_type)).to eq(["text/plain; charset=UTF-8", "text/html; charset=UTF-8"])
  end
end

def create_archivist
  user = create(:user)
  user.roles << Role.create(name: "archivist")
  user
end
