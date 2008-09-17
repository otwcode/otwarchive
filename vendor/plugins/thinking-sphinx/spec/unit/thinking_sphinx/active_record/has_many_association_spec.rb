require 'spec/spec_helper'

describe 'ThinkingSphinx::ActiveRecord::HasManyAssociation' do
  describe "search method" do
    before :each do
      Friendship.stub_method(:search => true)
      
      @person = Person.find(:first)
      @index  = Friendship.indexes.first
    end
    
    it "should raise an error if the required attribute doesn't exist" do
      @index.stub_method(:attributes => [])
      
      lambda { @person.friendships.search "test" }.should raise_error(RuntimeError)
      
      @index.unstub_method(:attributes)
    end
    
    it "should add a filter for the attribute into a normal search call" do
      @person.friendships.search "test"
      
      Friendship.should have_received(:search).with(
        "test", :with => {:person_id => @person.id}
      )
    end    
  end
  
  describe "search method for has_many :through" do
    before :each do
      Person.stub_method(:search => true)
      
      @person = Person.find(:first)
      @index  = Person.indexes.first
    end
    
    it "should raise an error if the required attribute doesn't exist" do
      @index.stub_method(:attributes => [])
      
      lambda { @person.friends.search "test" }.should raise_error(RuntimeError)
      
      @index.unstub_method(:attributes)
    end
    
    it "should add a filter for the attribute into a normal search call" do
      @person.friends.search "test"
      
      Person.should have_received(:search).with(
        "test", :with => {:friendly_ids => @person.id}
      )
    end
  end
end