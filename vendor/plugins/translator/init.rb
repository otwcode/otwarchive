#require 'translator'

Dir.glob(File.join(File.dirname(__FILE__), 'lib', 'scope_translator', '*.rb')).each{|f| require f}