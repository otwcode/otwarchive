require File.dirname(__FILE__) + "/../../spec_helper"

module FixtureReplacementController
  # These specs are ugly.  It probably means that I need to refactor AttributeCollection#to_new_class_instance
  describe AttributeCollection, "Send Regresssion" do
    before :each do
      @class = Class.new
      @instance = @class.new
      @class.stub!(:new).and_return @instance
      
      @instance.stub!(:foo=)
      
      @attributes = AttributeCollection.new(:foo, {})
      @attributes.stub!(:active_record_class).and_return @class
      @attributes.stub!(:hash).and_return({:foo => :bar})
    end
    
    it "should be able to send the message (to_new_class_instance), even if the send method has been redefined" do
      @instance.should_not_receive(:send)
      @instance.should_receive(:__send__)
      
      @attributes.to_new_class_instance
    end
  end
  
  describe AttributeCollection, "send regression, part 2" do
    before :each do
      @class = Class.new
      @instance = @class.new
      @class.stub!(:new).and_return @instance
      
      @instance.stub!(:foo=)
      
      @attributes = AttributeCollection.new(:foo, {})
      @attributes.stub!(:active_record_class).and_return @class

      @mock_who_cares = mock 'who cares'
      @mock_who_cares.stub!(:fixture_name)

      @value = DelayedEvaluationProc.new do
        @mock_who_cares
      end
      
      @attributes.stub!(:hash).and_return({:foo => @value})
      
      @caller = Object.new
      @caller.stub!(:send).and_raise
      @caller.stub!(:__send__)

    end
    
    it "should be able to send the message with __send__" do
      @caller.should_not_receive(:send)
      @caller.should_receive(:__send__)

      @attributes.to_new_class_instance({}, @caller)
    end

  end 
end
