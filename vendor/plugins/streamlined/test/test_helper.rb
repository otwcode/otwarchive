RAILS_ENV = "test" unless Object.const_defined?("RAILS_ENV")
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'test/unit'
require 'test/spec'
require 'mocha'
require 'flexmock/test_unit'
require 'ostruct'
require File.expand_path(File.join(File.dirname(__FILE__), "/lib/multi_rails/lib/multi_rails_init"))
require File.expand_path(File.join(File.dirname(__FILE__), "/lib/flexmock_patch"))
require File.expand_path(File.join(File.dirname(__FILE__), "edge_rails_test_helper"))
require 'generator'
begin # dont depend on redgreen
  require 'redgreen' unless Object.const_defined?("TextMate") 
rescue LoadError
  nil
end 
# Arts plugin from http://glu.ttono.us/articles/2006/05/29/guide-test-driven-rjs-with-arts
# Arts provides an easily understandable syntax for testing RJS templates
require File.expand_path(File.join(File.dirname(__FILE__), "/lib/arts"))

silence_stream(STDERR) do
  RAILS_ROOT = Pathname.new(File.join(File.dirname(__FILE__), '../faux_rails_root')).expand_path.to_s
  logfile = File.join(File.dirname(__FILE__), '../log/test.log')
  (RAILS_DEFAULT_LOGGER = Logger.new(logfile)).level = Logger::INFO
end
require 'initializer'
require "#{File.dirname(__FILE__)}/../init"
# must come after require init
require 'relevance/rails_assertions'
require 'relevance/controller_test_support'

(ActiveRecord::Base.logger = RAILS_DEFAULT_LOGGER).level = Logger::DEBUG

EdgeRailsTestHelper.bootstrap_test_environment_for_edge if Streamlined.edge_rails?

class Test::Unit::TestCase
  include Relevance::RailsAssertions
  include Streamlined::GenericView
  include Arts
        
  def reset_streamlined!
    Streamlined::PermanentRegistry.reset
    Streamlined::ReloadableRegistry.reset
  end
  
  def root_node(html) 
     HTML::Document.new(html).root
  end
  
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
  
  def assert_equal_sets(a,b,*args)
    assert_equal(Set.new(a), Set.new(b),*args)
  end
  
  # Note that streamlined hashes should be indifferent between keys and strings
  def assert_key_set(keys, hash)
    assert_kind_of(HashWithIndifferentAccess, hash)
    assert_equal(Set.new(keys), Set.new(hash.symbolize_keys.keys))
  end
  
  def assert_enum_of_same(expected, actual)
    g = Generator.new(actual)
    expected.each do |e|
      assert_same(e,g.next)
    end
    assert_equal false, g.next?, "actual enumeration larger than expected"
  end
  
  def assert_has_private_methods(inst, *methods)
    methods.each do |method|
      method = method.to_s
      assert(inst.private_methods.member?(method), "#{method} should be private on #{inst.class}")
    end
  end

  def assert_has_public_methods(inst, *methods)
    methods.each do |method|
      method = method.to_s
      assert(inst.public_methods.member?(method), "#{method} should be public on #{inst.class}")
    end
  end
end

