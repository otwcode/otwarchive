# We include an init file here to be easily required using a gemmed version of MultiRails
require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails"))
MultiRails::gem_and_require_rails
