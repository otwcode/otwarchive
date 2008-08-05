require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/controller/callbacks'

class StubController < ActionController::Base
  include Streamlined::Controller::Callbacks
end

describe "Streamlined::Controller::Callbacks" do
  
  def setup
    @controller = StubController.new
  end

  it "should call the method registered" do
    @controller.expects(:current_before_callback).with(:create).returns(:some_method)
    @controller.expects(:some_method).returns(:result)
    assert_equal :result, @controller.send(:execute_before_callback, :create)
  end
  
  it "execute doesn't yield if the callback returns false" do
    proc_called = false
    @controller.stubs(:current_before_callback).with(:any).returns(:not_nil)
    @controller.expects(:execute_before_callback).with(:any).returns(false)
    @controller.send(:execute, :any, &Proc.new{proc_called = true})
    proc_called.should == false
  end
    
end
