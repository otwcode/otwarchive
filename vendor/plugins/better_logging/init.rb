require 'active_support'
require File.join(File.dirname(__FILE__), "lib", "better_logging")
ActiveSupport::BufferedLogger.send(:include, PaulDowman::RailsPlugins::BetterLogging)
