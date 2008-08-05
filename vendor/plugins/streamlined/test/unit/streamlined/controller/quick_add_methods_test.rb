require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/controller/quick_add_methods'

class StubModel
  attr_accessor :attrs
  def initialize(attrs={})
    @attrs = attrs
  end
  def name
    "a stub model"
  end
end

class StubController < ActionController::Base
  include Streamlined::Controller::QuickAddMethods
  attr_accessor :crud_context, :instance, :model, :stub_model,
                :model_class_name, :model_name, :ui
end

module QuickAddMethodsTestHelper
  def assert_correct_vars_set
    assert @controller.instance.is_a?(StubModel)
    assert @controller.model.is_a?(StubModel)
    assert @controller.stub_model.is_a?(StubModel)
    assert_equal 'StubModel', @controller.model_class_name
    assert_equal 'stub_model', @controller.model_name    
    assert_instance_of Streamlined::UI, @controller.ui
  end
  
  def build_param_and_render_mocks(template)
    @controller.stubs(:params).returns({ :model_class_name => 'StubModel' })
    @controller.expects(:render_or_redirect).with(:success, template)
  end
end
       
describe "handling invalid QuickAdd attempts" do
  before do
    reset_streamlined!
    @controller = StubController.new
  end
  
  it "should render 403 for an unknown model" do
    @controller.expects(:render).with(:text => nil, :status => 403)
    @controller.stubs(:params).returns :model_class_name => "BadModel"
    @controller.quick_add
  end
  
  it "should render 403 for a non STreamlined model" do
    @controller.expects(:render).with(:text => nil, :status => 403)
    @controller.stubs(:params).returns :model_class_name => "Kernel"
    @controller.quick_add
  end    
  
end

describe "handling invalid QuickAdd object name methods" do
  before do
    @obj = Object.new
    class << @obj
      include Streamlined::Controller::QuickAddMethods
      public :get_object_name, :model_name_method_white_list
    end
  end

  it "keeps a white list" do
    @obj.model_name_method_white_list.should == ["name"]
  end 
  
  it "blows up get_object_name if the name method is not on the white list" do
    @obj.stubs(:params).returns({:model_name_method => "foo"})
    lambda { @obj.get_object_name(StubModel.new) }.should.raise(ArgumentError)
  end

  it "allows get_object_name if the name method is not on the white list" do
    @obj.stubs(:params).returns({:model_name_method => "name"})
    @obj.get_object_name(StubModel.new).should == "a stub model"
  end
end


describe "Streamlined::Controller::QuickAddMethods for relational delegate" do
  # TODO: test these actions with a class that uses delegation
end

describe "Streamlined::Controller::QuickAddMethods for non-relational delegate" do
  include QuickAddMethodsTestHelper

  before do
    reset_streamlined!
    @controller = StubController.new
    StubModel.stubs(:delegate_target_associations).returns([])
    StubModel.stubs(:reflect_on_association).returns(nil)
    @controller.stubs(:safe_to_instantiate?).returns(true)
  end
  
  it "quick add" do
    build_param_and_render_mocks('quick_add')
    @controller.quick_add
    assert_equal :new, @controller.crud_context
    assert_correct_vars_set
  end
  
  it "save quick add" do
    build_param_and_render_mocks('save_quick_add')
    StubModel.any_instance.expects(:save).returns(true)
    @controller.save_quick_add
    assert_nil @controller.crud_context
    @controller.instance_variable_get("@object_name").should == "a stub model"
    assert_correct_vars_set
  end
end

describe "Streamlined::Controller::QuickAddMethods" do
  include QuickAddMethodsTestHelper
  
  before do                          
    reset_streamlined!
    StubModel.stubs(:delegate_target_associations).returns([])
    @controller = StubController.new
    @controller.stubs(:safe_to_instantiate?).returns(true)
  end
  
  it "quick add" do
    build_param_and_render_mocks('quick_add')
    @controller.quick_add
    assert_equal :new, @controller.crud_context
    assert_correct_vars_set
  end
  
  it "save quick add" do
    build_param_and_render_mocks('save_quick_add')
    StubModel.any_instance.expects(:save).returns(true)
    @controller.save_quick_add
    assert_nil @controller.crud_context
    assert_correct_vars_set
  end
  
  
end