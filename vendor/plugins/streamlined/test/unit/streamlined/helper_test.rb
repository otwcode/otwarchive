require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))
require 'ostruct'

describe "Streamlined::Helper" do
              
  def setup                       
    @inst = OpenStruct.new
    @inst.extend Streamlined::Helper
  end

  it "relationship div id" do
    rel = flexmock(:name => "relationship-name", :class_name => "relationship-class-name")
    item = Class.new {attr_accessor :id}.new
    item.id = "item-id"
    @inst.relationships = {}
    @inst.model_ui = flexmock("model_ui") {|mock|
      mock.should_receive(:id_fragment).times(2).and_return("model-ui-fragment")
    }
    assert_equal "model-ui-fragment::relationship-name::item-id::relationship-class-name", @inst.relationship_div_id(rel, item)
    assert_equal "model-ui-fragment::relationship-name::item-id::relationship-class-name::win", @inst.relationship_div_id(rel, item, true)
  end
end
