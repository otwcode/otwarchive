require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails_test_helper"))

describe "Rubygem test helper init" do
  setup { never_puts }
  
  it "should call gem and require rails" do
    MultiRails.expects(:gem_and_require_rails).once
    load File.expand_path(File.join(File.dirname(__FILE__), "../lib/multi_rails_init.rb"))
  end
  
  it "should actually do the gem and require" do
    MultiRails::Loader.any_instance.expects(:require).never
    MultiRails::Loader.any_instance.expects(:gem_rails)
    MultiRails::Loader.any_instance.expects(:require_rails)
    load File.expand_path(File.join(File.dirname(__FILE__), "../lib/multi_rails_init.rb"))
  end
  
end