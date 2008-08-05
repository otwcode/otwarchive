require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))

describe "Streamlined::ReloadableRegistry" do

  before do
    (@rr = Streamlined::ReloadableRegistry).reset
    @clazz = Class.new
  end                                    
  
  it "should create and cache UI classes based on class name" do
    ui = @rr.ui_for(@clazz)
    ui.should.be.kind_of?(Streamlined::UI)
    ui2 = @rr.ui_for(@clazz)
    ui.should.be ui2
  end

  it "should create and cache separate UI classes based on optional :context" do
    ui = @rr.ui_for(@clazz)
    ui.should.be.kind_of Streamlined::UI
    ui_c1 = @rr.ui_for(@clazz, :context => :context_1)
    ui_c1.should.be.kind_of Streamlined::UI
    ui_c1.should.not.be ui
    ui_c2 = @rr.ui_for(@clazz, :context => :context_2)
    ui_c2.should.be.kind_of Streamlined::UI
    ui_c2.should.not.be ui
    ui_c2.should.not.be ui_c1
  end
end