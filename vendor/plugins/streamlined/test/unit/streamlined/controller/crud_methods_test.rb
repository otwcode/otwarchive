require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/controller/crud_methods'

describe "Streamlined::Controller::CrudMethods has_manies support" do

  before do
    @controller = OpenStruct.new
    @controller.extend Streamlined::Controller::CrudMethods
    @controller.instance = stub_everything
    class << @controller
      public :set_has_manies, :collect_has_manies
    end
  end
  
  it "should strip out STREAMLINED_SELECT_NONE when setting has_manies" do
    hash = {:foo => ["1", STREAMLINED_SELECT_NONE]}
    @controller.instance.expects(:foo).with(["1"])
    @controller.set_has_manies hash
  end
    
  it "collect_has_manies should return empty hash if no params passed in" do
    @controller.collect_has_manies(nil).should == {}
    @controller.collect_has_manies({}).should == {}
  end

  it "set_has_manies should return blank arg if blank arg passed in" do
    @controller.set_has_manies(nil).should == nil
    @controller.set_has_manies({}).should == {}
  end

end