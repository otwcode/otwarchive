ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

class Hash
  undef :ya2yaml
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  fixtures :all

  self.fixture_class_names = {:tolk_locales => 'Tolk::Locale', :tolk_phrases => 'Tolk::Phrase', :tolk_translations => 'Tolk::Translation'}
end
