require File.join(File.dirname(__FILE__), "../..", "example_helper.rb")

describe "Rails init.rb" do
  after { ENV.delete "RAILS_ENV" }
  
  pending "requires main tarantula file if in test environment" do
    ENV["RAILS_ENV"] = "test"
    path = File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. lib relevance tarantula]))
    Object.any_instance.expects(:require).with('rake')
    Object.any_instance.expects(:require).with path
    load File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. rails init.rb]))
  end
  
end
