require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails_test_helper"))

describe "install hook" do
  setup    { Object.const_set("RAILS_ROOT", "/src/rails_app") }
  teardown { Object.send(:remove_const, "RAILS_ROOT") if Object.const_defined?("RAILS_ROOT")}
  
  def load_install
    silence_warnings do
      load File.expand_path(File.join(File.dirname(__FILE__), "../install.rb"))
    end
  end
  
  it "should copy the multi_rails_runner to the script directory" do
    Object.any_instance.stubs(:puts).returns(nil)
    Object.any_instance.stubs(:`)
    
    FileUtils.expects(:symlink).with("#{RAILS_ROOT}/vendor/plugins/multi_rails/bin/multi_rails_runner.rb", 
      "script/multi_rails_runner", :force => true)
    load_install
  end
  
  it 'should make the file executable' do
    Object.any_instance.stubs(:puts).returns(nil)
    Object.any_instance.expects(:`).with("chmod +x #{RAILS_ROOT}/script/multi_rails_runner")
    File.stubs(:symlink)
    load_install
  end
  
end