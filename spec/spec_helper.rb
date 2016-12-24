ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
#require File.expand_path('../../features/support/factories.rb', __FILE__)
require 'simplecov'
require 'coveralls'
SimpleCov.command_name "rspec-" + (ENV['TEST_RUN'] || '')
Coveralls.wear_merged!('rails') unless ENV['TEST_LOCAL']
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
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  #config.raise_errors_for_deprecations!
  config.include FactoryGirl::Syntax::Methods
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include Capybara::DSL

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean
  end

  config.before :each do
    DatabaseCleaner.start
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
  #     describe ThingsController, :type => :controller do
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
  # Finally elastic search
  Tire::Model::Search.index_prefix Time.now.to_f.to_s
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
  user.roles << Role.new(name: "archivist")
  user
end
