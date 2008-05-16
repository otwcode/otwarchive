require File.dirname(__FILE__) + "/../spec_helper"

describe "FixtureReplacement.defaults_file" do
  before :each do
    remove_constant(:RAILS_ROOT)
    @rails_root = "script/../config/../config/.."
    Object.send(:const_set, :RAILS_ROOT, @rails_root)
    FixtureReplacement.instance_variable_set("@defaults_file", nil)
  end
  
  after :each do
    remove_constant(:RAILS_ROOT)
  end
  
  def remove_constant(constant)
    Object.send(:remove_const, constant) if Object.send(:const_defined?, constant)
  end  
  
  it "should be RAILS_ROOT/db/example_data.rb by default" do
    FixtureReplacement.defaults_file.should == "#{@rails_root}/db/example_data.rb"
  end
  
  it "should be foo.rb if set" do
    FixtureReplacement.defaults_file = "foo.rb"
    FixtureReplacement.defaults_file.should == "foo.rb"
  end
end