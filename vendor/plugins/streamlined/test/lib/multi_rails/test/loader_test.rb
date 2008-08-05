require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails_test_helper"))

describe "loader" do
  
  setup do
    never_really_require_rails
    never_puts
  end
  
  it "should fall back to a default version to try" do
    MultiRails::Loader.any_instance.stubs(:display_rails_gem_used)
    stub_rails_requires
    MultiRails::Loader.any_instance.expects(:gem).with("rails", MultiRails::Loader.latest_stable_version)
    MultiRails::Loader.gem_and_require_rails
  end
  
  it "should fail fast if we are missing a requested gem version" do
    lambda { MultiRails::Loader.gem_and_require_rails("9.9.9") }.should.raise(MultiRailsError)
  end
  
  it "should gem the specified version" do
    MultiRails::Loader.any_instance.stubs(:display_rails_gem_used)
    stub_rails_requires
    MultiRails::Loader.any_instance.expects(:gem).with("rails", "1.2.5").returns(true)
    MultiRails::Loader.gem_and_require_rails("1.2.5")
  end
  
  it "should allow using a better name for weird gem version numbers, like 2.0.0 PR => 1.2.4.7794" do
    MultiRails::Loader.any_instance.stubs(:display_rails_gem_used)
    MultiRails::Loader.stubs(:all_rails_versions).returns(["1.2.3", "1.2.4", "1.2.4.7794"])
    stub_rails_requires
    MultiRails::Loader.any_instance.expects(:gem).with("rails", MultiRails::Config.weird_versions["2.0.0.PR"]).returns(true)
    MultiRails::Loader.gem_and_require_rails("2.0.0.PR")
  end

  it "should require the needed dependancies" do
    MultiRails::Loader.any_instance.stubs(:display_rails_gem_used)
    MultiRails::Loader.any_instance.stubs(:gem)
    MultiRails::Config.rails_requires.each do |file|
      MultiRails::Loader.any_instance.expects(:require).with(file)
    end
    MultiRails::Loader.gem_and_require_rails
  end
  
  def stub_rails_requires
    MultiRails::Loader.any_instance.stubs(:require).returns(true)
  end
  
  def never_really_require_rails
    MultiRails::Loader.any_instance.expects(:require).never
  end
  
end

describe "finding all gems of rails available" do
  
  it "should find rails by name when retrieving all rails versions, in order to avoid false positives with other gems with rails in the name" do
    Gem::cache.expects(:find_name).with("rails").returns([])
    MultiRails::Loader.all_rails_versions
  end
  
  it "should return all Rails versions it finds sorted with the earliest versions first" do
    specs = [stub(:version => stub(:to_s => "1.2.4")), stub(:version => stub(:to_s => "1.2.3"))]
    Gem::cache.expects(:find_name).with("rails").returns(specs)
    MultiRails::Loader.all_rails_versions.should == ["1.2.3", "1.2.4"]
  end
  
end

describe "finding latest stable version" do
  it "should find the latest stable rails gem" do
    MultiRails::Loader.stubs(:all_rails_versions).returns(["1.2.3", "1.2.5", "1.2.5.1343"])
    MultiRails::Loader.latest_stable_version.should == "1.2.5"
  end  
  
  it "should find 2.0.0 when its released" do
    MultiRails::Loader.stubs(:all_rails_versions).returns(["1.2.3", "1.2.5", "1.2.5.1343", "2.0.0", "1.2.7"])
    MultiRails::Loader.latest_stable_version.should == "2.0.0"
  end  
  
end

describe "finding latest version" do
  it "should find the most recent version, regardless of edge or non edge versions" do
    MultiRails::Loader.stubs(:all_rails_versions).returns(["1.2.3", "1.2.5", "1.2.5.1343"])
    MultiRails::Loader.latest_version.should == "1.2.5.1343"
  end

  it "should return the only version you have if there is only one installed" do
    MultiRails::Loader.stubs(:all_rails_versions).returns(["1.2.3"])
    MultiRails::Loader.latest_version.should == "1.2.3"
  end
  
end
