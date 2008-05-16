#
# Bug Report:
#
#
# [#17249] String.random in a STI base class works, but doesn't work with inherited classes
# Date:
# 2008-01-20 14:01 	Priority:
# 3
# Submitted By:
# andy watts (andywatts) 	Assigned To:
# Nobody (None)
# Category:
# Console (script/console) 	State:
# Open
# Summary:
# String.random in a STI base class works, but doesn't work with inherited classes
# 
# Detailed description
# 
# Love the plugin, but seem to have found a bug with the latest FixtureReplacemnt2.
# 
# There appears to be a problem when a base STI class in example_data has a random string.
# The derived STI classes do not get a fresh random string with each call.
# 
# Eg.
# Given the below example_data.rb, repeated new_user/create_user will work fine.  
# Each call creating a new object with a new random string.
# 
# However the STI classes do not work as expected...
# new_player/create_player will always return an object with the same random string
# 
# 
#   attributes_for :user do |u|
#     u.first_name = "First_name_" + String.random
#     u.email = "#{u.first_name}@aaa.com"
#   end
# 
#   attributes_for :player, :from => :user, :class => Player
# 
# 
# Thanks
# Andy
# 	
require File.dirname(__FILE__) + "/../../spec_helper"

module FixtureReplacementControllerHelper2
  def setup_fixtures
    @module = Module.new do
      class << self
        include FixtureReplacement::ClassMethods
      end
      
      attributes_for :user do |u|
        u.key = "foo"
        u.username = random_string
      end
      
      attributes_for :player, :class => Player, :from => :user

    private
    
      def random_string
        String.random(55)
      end
    end

    FixtureReplacementController::ClassFactory.stub!(:fixture_replacement_module).and_return @module
    FixtureReplacementController::MethodGenerator.generate_methods
    self.class.send :include, @module
  end
end

module FixtureReplacementController
  
  describe "String.random" do
    include FixtureReplacementControllerHelper2
    
    before :each do
      setup_fixtures
    end
    
    it "should have a different string for each instance in the base class" do
      user1 = create_user
      user2 = create_user
      user1.username.should_not == user2.username
    end
    
    it "should have a different string for each instance in the inherited class (with STI)" do
      player1 = create_player
      player2 = create_player
      player1.username.should_not == player2.username
    end
  end
end