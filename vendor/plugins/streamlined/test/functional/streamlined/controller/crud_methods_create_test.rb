require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))
require 'streamlined/controller/crud_methods'
require 'streamlined/controller/filter_methods'

describe "create with a before_streamlined_create filter" do
  attr_reader :controller
  setup do
    stock_controller_and_view(PoetsController)
  end
  
  it "should redirect after valid save" do
    @controller.class.before_streamlined_create(lambda { @poet.first_name = "Barack"; @poet.last_name = "Obama" })
    post :create, {:poet => {:first_name => "George", :last_name => "Bush" } }
    assert_response :redirect
  end
  
  it "should do the filter before the save" do
    @controller.class.before_streamlined_create(lambda { @poet.first_name = "Barack"; @poet.last_name = "Obama" })
    post :create, {:poet => {:first_name => "George", :last_name => "Bush" } }
    assigns(:streamlined_item).first_name.should == "Barack"
    assigns(:streamlined_item).last_name.should == "Obama"
  end
  
end

describe "creating with has many relationships" do
  setup do
    stock_controller_and_view(PoetsController)
  end
  
  it "should save the has_many side after the parent" do
    params = {:poet => {:first_name => "John", :last_name => "Doe", :poems => ["1", "2", STREAMLINED_SELECT_NONE] } }
    post :create, params
    assigns(:streamlined_item).poem_ids.sort.should == [1,2]
  end
  
  it "should clear has_manies if only the streamlined special 'none' value is sent" do
    params = {:poet => {:first_name => "John", :last_name => "Doe", :poems => [STREAMLINED_SELECT_NONE] } }
    post :create, params
    assigns(:streamlined_item).poems.should == []
  end
  
end

describe "editing has many relationships" do
  fixtures :poets, :poems
  setup do
    stock_controller_and_view(PoetsController)
  end
  
  it "should clear existing has manies when user posts only the special STREAMLINED_SELECT_NONE" do
    poet = poets(:justin)
    poet.poems.size.should >= 1
    params = {:id => poet.id, :poet => {:poems => [STREAMLINED_SELECT_NONE] } }
    post :update, params
    poet.poems.should == []
  end

  it "should update has manies and ignore STREAMLINED_SELECT_NONE when user posts real ids" do
    poet = poets(:justin)
    poet.poems.size.should >= 1
    params = {:id => poet.id, :poet => {:poems => ["1", "2", STREAMLINED_SELECT_NONE] } }
    post :update, params
    poet.poems.size.should == 2
  end
end
