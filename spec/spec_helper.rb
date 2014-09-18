ENV["RAILS_ENV"] ||= 'test'

# Coverals needs to work here too
require 'coveralls'
Coveralls.wear_merged!('rails')
SimpleCov.merge_timeout 3600

require File.expand_path("../../config/environment", __FILE__)
#require File.expand_path('../../features/support/factories.rb', __FILE__)
require 'rspec/rails'
require 'factory_girl'
require 'database_cleaner'
require 'email_spec'



# SimpleCov integration

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start 'rails' do
  add_filter '/features/'
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Views', 'app/views'

end


DatabaseCleaner.start

DatabaseCleaner.clean


# SimpleCov integration

require 'simplecov'

SimpleCov.start 'rails' do
  add_filter '/features/'
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Views', 'app/views'
end

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
  config.include FactoryGirl::Syntax::Methods
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.include Capybara::DSL

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
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
end

def get_message_part (mail, content_type)
  mail.body.parts.find { |p| p.content_type.match content_type }.body.raw_source
end

shared_examples_for "multipart email" do
  it "generates a multipart message (plain text and html)" do
    email.body.parts.length.should eq(2)
    email.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
  end
end
