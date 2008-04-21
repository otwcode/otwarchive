$:.unshift(File.dirname(__FILE__) + '/../lib')

ENV['RAILS_ENV'] = 'test'

require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'breakpoint'
require 'action_controller/test_process'

class Test::Unit::TestCase #:nodoc:
  include ActionController::TestProcess
end
