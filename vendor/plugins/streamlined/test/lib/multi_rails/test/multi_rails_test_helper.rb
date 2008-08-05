require 'test/unit'
require 'test/spec'
require 'mocha'
require 'redgreen' unless Object.const_defined?("TextMate")

require File.expand_path(File.join(File.dirname(__FILE__), "../lib/multi_rails"))

class Test::Unit::TestCase
  def never_puts
    MultiRails::Loader.stubs(:puts)
    MultiRails::Loader.any_instance.stubs(:puts)
  end
end
