require 'test/unit'
require 'rubygems'
require 'active_support'

$:.unshift File.join(File.dirname(__FILE__), '../lib')

RAILS_ROOT = '.' unless defined?(RAILS_ROOT)
