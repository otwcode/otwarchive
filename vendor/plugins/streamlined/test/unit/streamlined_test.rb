require File.expand_path(File.join(File.dirname(__FILE__), '/../test_helper'))

describe "Streamlined" do
       
  before do
    Streamlined::PermanentRegistry.reset
    Streamlined::ReloadableRegistry.reset
  end                          
  
  after do
    Streamlined::PermanentRegistry.reset
    Streamlined::ReloadableRegistry.reset
  end
                 
  it "caches UI instances for Streamlined models" do
    ui_stub = stub
    Streamlined::UI.expects(:new).returns(ui_stub).once
    Streamlined::ui_for("SomeModel").should == ui_stub
    Streamlined::ui_for("SomeModel").should == ui_stub
  end

  it "bad format" do
    error = assert_raises(ArgumentError) {Streamlined.display_format_for("Forgot proc argument")}
    assert_equal "Block required", error.message
  end
  
  it "single format for display" do
    format_gandalf_for_display
  end                               
  
  it "single format for edit" do
    format_voldemort_for_edit
  end
  
  it "multiple formats" do
    format_gandalf_for_display
    format_fingolfin_for_display      
    format_voldemort_for_edit
  end
  
  it "reset formats" do
    format_gandalf_for_display
    format_fingolfin_for_display
    format_voldemort_for_edit
    Streamlined::PermanentRegistry.reset
    assert_equal "Gandalf", Streamlined.format_for_display("Gandalf")
    assert_equal "Fingolfin", Streamlined.format_for_display("Fingolfin")
    assert_equal "Voldemort", Streamlined.format_for_edit("Voldemort")
  end
  
  it "should return true for edge rails if edge rails features are present" do
    ActionController::Base.expects(:respond_to?).with(:view_paths=).returns(true)
    assert Streamlined.edge_rails?
  end
  
  it "should return false for edge rails if edge rails features are not present" do
    ActionController::Base.expects(:respond_to?).with(:view_paths=).returns(false)
    assert_false Streamlined.edge_rails?
  end
  
  private 
  
  def format_gandalf_for_display
    assert_equal "Gandalf", Streamlined.format_for_display("Gandalf")
    Streamlined.display_format_for("Gandalf") do |obj|
      "#{obj} is a wizard!"
    end
    assert_equal "Gandalf is a wizard!", Streamlined.format_for_display("Gandalf")
  end
  
  def format_fingolfin_for_display
    assert_equal "Fingolfin", Streamlined.format_for_display("Fingolfin")
    Streamlined.display_format_for("Fingolfin") do |obj|
      "#{obj} is an elf!"
    end
    assert_equal "Fingolfin is an elf!", Streamlined.format_for_display("Fingolfin")
  end
  
  def format_voldemort_for_edit
    assert_equal "Voldemort", Streamlined.format_for_edit("Voldemort")
    Streamlined.edit_format_for("Voldermort") do |obj|
      "He Who Must Not Be Named"
    end
    assert_equal "He Who Must Not Be Named", Streamlined.format_for_edit("Voldermort")
  end
  
  
end