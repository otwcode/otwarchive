require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/helpers/form_helper'

describe "Streamlined::FormHelper" do
  include Streamlined::Helpers::FormHelper
  
  it "unassigned if allowed with model that has no validations" do
    model_class, column = flexmock, flexmock(:unassigned_value => 'none', :name => 'name')
    model_class.should_receive(:respond_to?).with('reflect_on_validations_for').and_return(true).once
    model_class.should_receive(:reflect_on_validations_for).with('name').and_return([])
    assert_equal "<option value='nil' selected>none</option>", unassigned_if_allowed(model_class, column, nil)
  end
  
  it "unassigned if allowed with model that has validations" do
    model_class, column = flexmock, flexmock(:unassigned_value => 'none', :name => 'name')
    model_class.should_receive(:respond_to?).with('reflect_on_validations_for').and_return(true).once
    model_class.should_receive(:reflect_on_validations_for).with('name').and_return([flexmock(:macro => :validates_presence_of)])
    assert_equal '', unassigned_if_allowed(model_class, column, nil)
  end
  
  it "column can be unassigned with nils" do
    assert column_can_be_unassigned?(nil, nil)
  end
  
  it "column required returns false if validation reflection isnt available" do
    assert_false column_required?(stub, "column_name")
  end
  
  it "column required returns false if validates presence of is not present" do
    ar_model = stub
    ar_model.stubs(:reflect_on_validations_for).returns([])    
    assert_false column_required?(ar_model, "column_name")
  end

  it "column required returns true if validates presence of is present" do
    ar_model = stub
    ar_model.stubs(:reflect_on_validations_for).with("column_name").returns([stub(:macro => :validates_presence_of)])
    assert_true column_required?(ar_model, "column_name")
  end

  it "column required returns true if validates presence of column id is present" do
    ar_model = stub
    ar_model.stubs(:reflect_on_validations_for).with("column_name").returns([])
    ar_model.stubs(:reflect_on_validations_for).with("column_name_id").returns([stub(:macro => :validates_presence_of)])
    assert_true column_required?(ar_model, "column_name")
  end
end