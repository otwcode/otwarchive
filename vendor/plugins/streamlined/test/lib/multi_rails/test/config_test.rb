require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails_test_helper"))

describe "Version Lookup in config" do
  
  it "should use argument version if passed in " do
    MultiRails::Loader.stubs(:all_rails_versions).returns(["1.2.3", "1.2.4"])
    MultiRails::Config.version_lookup("1.2.3").should == "1.2.3"
  end
  
  it "should use env var if set" do
    begin
      MultiRails::Loader.stubs(:all_rails_versions).returns(["1.2.99"])
      ENV["MULTIRAILS_RAILS_VERSION"] = "1.2.99"
      MultiRails::Config.version_lookup.should == "1.2.99"
    ensure
      silence_warnings { ENV["MULTIRAILS_RAILS_VERSION"] = nil }
    end
  end
  
  it "should raise if providing env var and we dont find a corresponding version" do
    begin
      ENV["MULTIRAILS_RAILS_VERSION"] = "X.X.99"
      lambda { MultiRails::Config.version_lookup }.should.raise(MultiRailsError)
    ensure
      silence_warnings { ENV["MULTIRAILS_RAILS_VERSION"] = nil }
    end
  end
  
  it "should use latest stable version if there is no argumnt or env var" do
    MultiRails::Config.version_lookup.should == MultiRails::Loader.latest_stable_version
  end
end

describe "getting the rails load path " do
  it "should grab only the real rails paths, and ignore false rails directories in the load path" do
    load_path = ["/Users/rsanheim/src/relevance/essi/trunk/essi/vendor/plugins/test_spec_on_rails/lib",
      "/Users/rsanheim/src/relevance/essi/trunk/essi/vendor/plugins/rails_env/lib",
      "/opt/local/lib/ruby/gems/1.8/gems/rails-2.0.1/lib/../builtin/rails_info/", "/opt/local/lib/ruby/gems/1.8/gems/rails-2.0.1/lib",
      "/opt/local/lib/ruby/gems/1.8/gems/rails-2.0.1/bin", "/Users/rsanheim/src/project/trunk/foo/vendor/gems/rails_env-0.4.0/lib"]
    MultiRails::Config.stubs(:load_path).returns(load_path)
    MultiRails::Config.rails_load_path.should == "rails-2.0.1"
  end
  
  it "should use the real load path" do
    MultiRails::Config.load_path.should == $LOAD_PATH
  end
  
  it "should return nil if we can't figure out the rails version" do
    load_path = ["/Users/rsanheim/src/relevance/essi/trunk/essi/vendor/plugins/test_spec_on_rails/lib",
      "/Users/rsanheim/src/relevance/essi/trunk/essi/vendor/plugins/rails_env/lib"]
    MultiRails::Config.stubs(:load_path).returns(load_path)
    MultiRails::Config.rails_load_path.should == nil
  end
end
