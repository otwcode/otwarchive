lib_path = File.expand_path(File.dirname(__FILE__) + "/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'rubygems'
gem "spicycode-micronaut", ">= 0.2.0"
gem "log_buddy"
gem "mocha"
gem 'ruby-debug'
gem 'test-spec'
gem 'actionpack'
gem 'activerecord'
gem 'activesupport'

require 'ostruct'
require 'ruby-debug'
require 'activerecord'
require 'relevance/tarantula'
require 'micronaut'
require 'mocha'

# needed for html-scanner, grr
require 'active_support'
require 'action_controller'

def test_output_dir
  File.join(File.dirname(__FILE__), "..", "tmp", "test_output")
end

# TODO change puts/print to use a single method for logging, which will then make the stubbing cleaner
def stub_puts_and_print(obj)
  obj.stubs(:puts)
  obj.stubs(:print)
end

def not_in_editor?
  ['TM_MODE', 'EMACS', 'VIM'].all? { |k| !ENV.has_key?(k) }
end

def in_runcoderun?
  ENV["RUN_CODE_RUN"]
end

Micronaut.configure do |c|
  c.formatter = :documentation if in_runcoderun?
  c.alias_example_to :fit, :focused => true
  c.alias_example_to :xit, :disabled => true
  c.mock_with :mocha
  c.color_enabled = not_in_editor?
  c.filter_run :focused => true
end
