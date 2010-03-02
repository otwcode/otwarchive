require 'rubygems'
require 'test/unit'
require 'action_controller'
require 'active_record'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'repeated_auto_complete'
require File.join(File.dirname(__FILE__), '..', 'rails', 'init')

class Test::Unit::TestCase
end

ActiveRecord::Base.establish_connection({ :adapter => 'sqlite3', :database => ':memory:' })
