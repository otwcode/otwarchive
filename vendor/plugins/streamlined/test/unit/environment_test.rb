require File.expand_path(File.join(File.dirname(__FILE__), '/../test_helper'))

describe "StreamlinedEnvironment" do
  
  it "pagination is available" do
    assert defined?(ActionController::Pagination) 
  end
  
  it "should require pagination plugin" do
    ignore_any_dynamic_constants_set
    Streamlined::Environment.expects(:require_streamlined_plugin).with(:classic_pagination)
    Streamlined::Environment.init_environment
  end

  it "should setup constants" do
    ignore_any_dynamic_constants_set
    Streamlined::Environment.expects(:init_streamlined_constants)
    Streamlined::Environment.init_environment
  end
  
  it "should use absolute path for streamlined root if the path exists and is a directory" do
    path_in_actual_rails_app = File.expand_path(File.join(RAILS_ROOT, "vendor/plugins/streamlined"))
    Pathname.any_instance.expects(:directory?).returns(true)
    Streamlined::Environment.find_streamlined_root.should == path_in_actual_rails_app
  end
  
  it "should fallback to two directories up for streamlined root if necessary" do
    path = File.expand_path(File.join(File.dirname(__FILE__), "../../"))
    Pathname.any_instance.expects(:directory?).returns(false)
    Streamlined::Environment.find_streamlined_root.should == path
  end
  
  it "should use absolute path for streamlined template root" do
    Pathname.new(Streamlined::Environment.find_template_root).should.not.be.relative
  end
  
  # avoid errors by not actually setting constants in the test
  def ignore_any_dynamic_constants_set
    Object.stubs(:const_set)
  end
end