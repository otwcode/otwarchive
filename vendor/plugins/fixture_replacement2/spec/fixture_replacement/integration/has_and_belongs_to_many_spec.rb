require File.dirname(__FILE__) + "/../../spec_helper"

module HasAndBelongsToManyHelper
  def setup_fixtures
    @module = Module.new do
      class << self
        include FixtureReplacement::ClassMethods
      end      

      attributes_for :subscriber do |s|
        s.first_name = "Scott"
        s.subscriptions = [default_subscription]
      end
      
      attributes_for :subscription do |s|
        s.name = "The New York Times"
      end
      
      attributes_for :subscriber_with_two_subscriptions, :from => :subscriber, :class => Subscriber do |s|
        s.subscriptions = [default_harpers_subscription, default_ny_times_subscription]
      end
      
      attributes_for :harpers_subscription, :class => Subscription do |s|
        s.name = "Harper's Magazine"
      end
      
      attributes_for :ny_times_subscription, :from => :subscription, :class => Subscription
    end
    
    
    FixtureReplacementController::ClassFactory.stub!(:fixture_replacement_module).and_return @module
    FixtureReplacementController::MethodGenerator.generate_methods
    self.class.send :include, @module
  end
end

module FixtureReplacementController
  describe "HasAndBelongsToMany Associations" do
    include HasAndBelongsToManyHelper
    
    before :each do
      setup_fixtures
    end

    it "should have the fixture create_subscriber" do
      @module.should respond_to(:create_subscriber)
    end
    
    it "should have the fixture create_subscription" do
      @module.should respond_to(:create_subscription)
    end
    
    it "should be able to create a new subscriber" do
      lambda {
        @module.create_subscriber
      }.should_not raise_error
    end
    
    it "should have the subscriber with the default subscription" do
      subscriber = @module.create_subscriber
      subscriber.should have(1).subscription
      subscriber.subscriptions.first.name.should == "The New York Times"
    end
    
    it "should be able to create a subscriber with two subscriptions (inline)" do
      subscription_one = create_harpers_subscription
      subscription_two = create_ny_times_subscription
      
      subscriptions = [subscription_one, subscription_two]
      
      subscriber = @module.create_subscriber(:subscriptions => subscriptions)
      
      subscriber.subscriptions.should == subscriptions
    end
    
    it "should be able to create a subscriber with two subscriptions, from the fixtures" do
      subscriber = @module.create_subscriber_with_two_subscriptions
      subscriber.should have(2).subscriptions
    end
  end
end