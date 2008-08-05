require 'tempfile'
require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails_test_helper"))

describe "running a task" do
  setup { Object.const_set("RAILS_ROOT", "/src/rails_app")}
  teardown { Object.send(:remove_const, "RAILS_ROOT")}
  
  it "should call the bootstrap method if thats the task" do
    MultiRails::RailsAppHelper.expects(:bootstrap_for_rails)
    MultiRails::RailsAppHelper.run('bootstrap')
  end
  
  it "should invoke the corresponding rake task for any other arg" do
    task = mock().expects(:invoke)
    Rake::Task.expects(:[]).with("test:multi_rails:all").returns(task)
    MultiRails::RailsAppHelper.run('all')
  end
  
end

describe "determing rails root" do
  teardown { Object.send(:remove_const, "RAILS_ROOT") if Object.const_defined?("RAILS_ROOT")}
  
  it "should try the RAILS_ROOT constant first" do
    Object.const_set("RAILS_ROOT", "/src/rails_app")
    MultiRails::RailsAppHelper.set_rails_root.should == "/src/rails_app"
  end
  
  it "should fallback to finding it dynamically" do
    current_dir_stub = "/foo/bar/my_rails_app"
    Dir.expects(:entries).returns(["app", "lib", "config", "public", "test", "vendor"]).at_least_once
    Dir.expects(:pwd).returns(current_dir_stub).at_least_once
    MultiRails::RailsAppHelper.set_rails_root.should == "/foo/bar/my_rails_app"
  end
  
  it "should fail fast if it can't determine RAILS ROOT" do
    MultiRails::RailsAppHelper.expects(:find_rails_root_dir).returns(nil)
    lambda { MultiRails::RailsAppHelper.set_rails_root }.should.raise
  end
  
end

describe "writing rails gem version file" do
  setup { Object.const_set("RAILS_ROOT", "/src/rails_app")}
  teardown { Object.send(:remove_const, "RAILS_ROOT")}

  it "should write to the correct file" do
    File.expects(:open).with("#{RAILS_ROOT}/config/rails_version.rb", 'w')
    MultiRails::RailsAppHelper.write_rails_gem_version_file('1.2.5')
  end
  
end

describe "init for rails app" do
  it "should set rails root, write rails gem version file, and rename vendor rails" do
    version = "1.2.6"
    MultiRails::RailsAppHelper.expects(:set_rails_root)
    MultiRails::RailsAppHelper.expects(:write_rails_gem_version_file).with(version)
    MultiRails::RailsAppHelper.expects(:rename_vendor_rails_if_necessary)
    MultiRails::RailsAppHelper.init_for_rails_app(version)
  end
end

describe "renaming vendor/rails if it exists" do
  setup { Object.const_set("RAILS_ROOT", "/src/rails_app")}
  teardown { Object.send(:remove_const, "RAILS_ROOT")}
  
  it "should rename with .OFF extension so that gem version is picked up during test run" do
    vendor_rails = "#{RAILS_ROOT}/vendor/rails"
    File.stubs(:directory?).returns(true)
    File.expects(:rename).with(vendor_rails, "#{vendor_rails}.off")
    MultiRails::RailsAppHelper.rename_vendor_rails_if_necessary
  end
  
  it "should do nothing if there is no vendor/rails" do
    File.expects(:directory?).returns(false)
    File.expects(:rename).never
    MultiRails::RailsAppHelper.rename_vendor_rails_if_necessary
  end
end

describe "adding require hook to top of environment.rb using mocks" do
  setup { Object.const_set("RAILS_ROOT", "/src/rails_app")}
  teardown { Object.send(:remove_const, "RAILS_ROOT")}
  
  it "should raise if it can't find environment.rb" do
    e = lambda { MultiRails::RailsAppHelper.add_require_line_to_environment_file }.should.raise(MultiRailsError)
  end
  
  it "should not do anything if the line is already in the file" do
    File.stubs(:exist?).returns(true)
    File.expects(:open).never
    MultiRails::RailsAppHelper.expects(:first_environment_line).returns(MultiRails::RailsAppHelper::REQUIRE_LINE)
    MultiRails::RailsAppHelper.add_require_line_to_environment_file
  end
  
end

describe "adding require hook to top of environment.rb (without using mocks)" do
  
  setup do
    Object.const_set("RAILS_ROOT", "/src/rails_app")
    @env_content = <<-EOL
# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.5' unless defined? RAILS_GEM_VERSION
EOL
    @file = Tempfile.new('sample_environment')
    @file << @env_content
    @file.close
  end
  
  teardown do
    Object.send(:remove_const, "RAILS_ROOT")
  end
  
  it "should add the require line" do
    MultiRails::RailsAppHelper.stubs(:environment_file).returns(@file.path)
    MultiRails::RailsAppHelper.add_require_line_to_environment_file
    @file.open.rewind
    lines = @file.readlines
    lines[0].to_s.should == (MultiRails::RailsAppHelper::REQUIRE_LINE + "\n")
    lines[1..-1].to_s.should == @env_content
  end
  
end