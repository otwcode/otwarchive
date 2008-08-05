require File.dirname(__FILE__) + '/../../test_helper'
  
describe "Relevance::HashInit" do
  def setup
    @c = Class.new do
      attr_accessor :one, :two
      include HashInit
    end
  end
  
  it "initialize" do
    inst = @c.new(:one=>1, :two=>2)
    assert_equal(1, inst.one)
    assert_equal(2, inst.two)
  end
  
  it "should handle empty initialize" do
    assert_nothing_raised { @c.new }
  end
  
  it "should handle nil initialize" do
    assert_nothing_raised { @c.new(nil) }
  end
  
  it "can yield a block, too" do
    @inst = @c.new(:one => "value one") do |i|
      i.two = "value two"
    end
    @inst.one.should == "value one"
    @inst.two.should == "value two"
  end
end