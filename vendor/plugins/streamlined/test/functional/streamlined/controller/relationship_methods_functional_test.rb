require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))

describe "RelationshipMethodsFunctional" do
  def setup
    Streamlined::ReloadableRegistry.reset
    @controller = PeopleController.new
    class <<@controller
      public :crud_context=, :context_column
    end
    @person_ui = Streamlined.ui_for(Person) do
      show_columns :first_name, :last_name
    end
  end

  it "context column nil" do
    @controller.crud_context = nil
    assert_same @controller.context_column("first_name"),
                @person_ui.column("first_name") 
  end
  
  it "context column not nil" do
    @controller.crud_context = "show"            
    assert_not_same @controller.context_column("first_name"),
                    @person_ui.column("first_name") 
    assert_same @controller.context_column("first_name"),
                @person_ui.column("first_name", :crud_context => "show")
  end
  
end