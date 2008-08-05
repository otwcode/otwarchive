require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/controller'

require "#{RAILS_ROOT}/app/controllers/application"
class FooController < ApplicationController
end

describe "Streamlined::Controller" do
  include Streamlined::Controller::ClassMethods
  
  before do
    @clazz = Class.new
    @clazz.extend Streamlined::Controller::ClassMethods 
  end
  
  it "initialize streamlined controller context" do
    @clazz.expects(:delegate_non_routable)
    @clazz.initialize_streamlined_controller_context("Foo")
    context = @clazz.streamlined_controller_context
    context.should.be.instance_of Streamlined::Context::ControllerContext
  end
  
  it "streamlined model" do
    @clazz.expects(:delegate_non_routable)
    @clazz.initialize_streamlined_controller_context("Foo")
    @clazz.model_name.should == "Foo"
    @clazz.streamlined_ui("Bar")
    @clazz.model_name.should == "Bar"
  end  
  
  it "render filter" do
    options = { :success => { :action => 'foo' }}
    render_filter :show, options
    assert_equal options, render_filters[:show]
  end
  
  it "should have empty hashes for the filter readers by default" do
    assert_equal({}, filters)
    assert_equal({}, render_filters)
  end
  
  it "count or find options" do
    assert_equal({}, count_or_find_options)
    count_or_find_options(:foo => :bar)
    assert_equal({:foo => :bar}, count_or_find_options)
    count_or_find_options(:abc => :def)
    assert_equal({:abc => :def}, count_or_find_options)
  end
  
  it "should raise if trying to register an invalid callback" do
    lambda { FooController.before_streamlined_create(nil) }.should.
      raise(ArgumentError).
      message.should == "Invalid options for db_action_filter - must pass either a Proc or a Symbol, you gave [nil]"
  end
  
end