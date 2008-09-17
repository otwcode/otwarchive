require 'spec/spec_helper'

describe "ThinkingSphinx::ActiveRecord::Delta" do
  describe "after_commit callback" do
    before :each do
      Person.stub_method(:write_inheritable_array => true)
    end

    # This spec only passes with ActiveRecord 2.0.2 or earlier.
    # it "should add callbacks" do
    #   Person.after_commit :toggle_delta
    #   
    #   Person.should have_received(:write_inheritable_array).with(
    #     :after_commit, [:toggle_delta]
    #   )
    # end
    
    it "should have an after_commit method by default" do
      Person.instance_methods.should include("after_commit")
    end
  end
  
  describe "save_with_after_commit_callback method" do
    before :each do
      @person = Person.new
      @person.stub_methods(
        :save_without_after_commit_callback => true,
        :callback                           => true
      )
    end
    
    it "should call the normal save method" do
      @person.save
      
      @person.should have_received(:save_without_after_commit_callback)
    end
    
    it "should call the callbacks if the save was successful" do
      @person.save
      
      @person.should have_received(:callback).with(:after_commit)
    end
    
    it "shouldn't call the callbacks if the save failed" do
      @person.stub_method(:save_without_after_commit_callback => false)
      
      @person.save
      
      @person.should_not have_received(:callback)
    end
    
    it "should return the normal save's result" do
      @person.save.should be_true
      
      @person.stub_method(:save_without_after_commit_callback => false)
      
      @person.save.should be_false
    end
  end
  
  describe "save_with_after_commit_callback! method" do
    before :each do
      @person = Person.new
      @person.stub_methods(
        :save_without_after_commit_callback! => true,
        :callback                            => true
      )
    end
    
    it "should call the normal save! method" do
      @person.save!
      
      @person.should have_received(:save_without_after_commit_callback!)
    end
    
    it "should call the callbacks if the save! was successful" do
      @person.save!
      
      @person.should have_received(:callback).with(:after_commit)
    end
    
    it "shouldn't call the callbacks if the save! failed" do
      @person.stub_method(:save_without_after_commit_callback! => false)
      
      @person.save!
      
      @person.should_not have_received(:callback)
    end
    
    it "should return the normal save's result" do
      @person.save!.should be_true
      
      @person.stub_method(:save_without_after_commit_callback! => false)
      
      @person.save!.should be_false
    end
  end
  
  describe "destroy_with_after_commit_callback method" do
    before :each do
      @person = Person.new
      @person.stub_methods(
        :destroy_without_after_commit_callback  => true,
        :callback                               => true
      )
    end
    
    it "should call the normal destroy method" do
      @person.destroy
      
      @person.should have_received(:destroy_without_after_commit_callback)
    end
    
    it "should call the callbacks if the destroy was successful" do
      @person.destroy
      
      @person.should have_received(:callback).with(:after_commit)
    end
    
    it "shouldn't call the callbacks if the destroy failed" do
      @person.stub_method(:destroy_without_after_commit_callback => false)
      
      @person.destroy
      
      @person.should_not have_received(:callback)
    end
    
    it "should return the normal save's result" do
      @person.destroy.should be_true
      
      @person.stub_method(:destroy_without_after_commit_callback => false)
      
      @person.destroy.should be_false
    end
  end
  
  describe "toggle_delta method" do
    it "should set the delta value to true" do
      @person = Person.new
      
      @person.delta.should be_false
      @person.send(:toggle_delta)
      @person.delta.should be_true
    end
  end
  
  describe "index_delta method" do
    before :each do
      ThinkingSphinx::Configuration.stub_method(:environment => "spec")
      ThinkingSphinx.stub_method(:deltas_enabled? => true)
      
      @person = Person.new
      @person.stub_method(:system => true, :in_core_index? => false)
      
      @client = Riddle::Client.stub_instance(:update => true)
      Riddle::Client.stub_method(:new => @client)
    end
    
    it "shouldn't index if delta indexing is disabled" do
      ThinkingSphinx.stub_method(:deltas_enabled? => false)
      
      @person.send(:index_delta)
      
      @person.should_not have_received(:system)
      @client.should_not have_received(:update)
    end
    
    it "shouldn't index if index updating is disabled" do
      ThinkingSphinx.stub_method(:updates_enabled? => false)
      
      @person.send(:index_delta)
      
      @person.should_not have_received(:system)
    end
    
    it "shouldn't index if the environment is 'test'" do
      ThinkingSphinx.unstub_method(:deltas_enabled?)
      ThinkingSphinx::Configuration.stub_method(:environment => "test")
      
      @person.send(:index_delta)
      
      @person.should_not have_received(:system)
    end
    
    it "should call indexer for the delta index" do
      @person.send(:index_delta)
      
      @person.should have_received(:system).with(
        "indexer --config #{ThinkingSphinx::Configuration.new.config_file} --rotate person_delta"
      )
    end
    
    it "shouldn't update the deleted attribute if not in the index" do
      @person.send(:index_delta)
      
      @client.should_not have_received(:update)
    end
    
    it "should update the deleted attribute if in the core index" do
      @person.stub_method(:in_core_index? => true)
      
      @person.send(:index_delta)
      
      @client.should have_received(:update)
    end
  end
end
