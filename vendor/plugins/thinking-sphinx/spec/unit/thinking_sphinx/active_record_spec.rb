require 'spec/spec_helper'

describe "ThinkingSphinx::ActiveRecord" do
  describe "define_index method" do
    before :each do
      module TestModule
        class TestModel < ActiveRecord::Base; end
      end
      
      TestModule::TestModel.stub_methods(
        :before_save    => true,
        :after_commit   => true,
        :after_destroy  => true
      )
      
      @index = ThinkingSphinx::Index.stub_instance(:delta? => false)
      ThinkingSphinx::Index.stub_method(:new => @index)
    end
    
    after :each do
      # Remove the class so we can redefine it
      TestModule.send(:remove_const, :TestModel)
      
      ThinkingSphinx.indexed_models.delete "TestModule::TestModel"
    end
    
    it "should return nil and do nothing if indexes are disabled" do
      ThinkingSphinx.stub_method(:define_indexes? => false)
      
      TestModule::TestModel.define_index {}.should be_nil
      ThinkingSphinx::Index.should_not have_received(:new)
      
      ThinkingSphinx.unstub_method(:define_indexes?)
    end
    
    it "should add a new index to the model" do
      TestModule::TestModel.define_index do; end
      
      TestModule::TestModel.indexes.length.should == 1
    end
    
    it "should add to ThinkingSphinx.indexed_models if the model doesn't already exist in the array" do
      TestModule::TestModel.define_index do; end
      
      ThinkingSphinx.indexed_models.should include("TestModule::TestModel")
    end
    
    it "shouldn't add to ThinkingSphinx.indexed_models if the model already exists in the array" do
      TestModule::TestModel.define_index do; end
      
      ThinkingSphinx.indexed_models.select { |model|
        model == "TestModule::TestModel"
      }.length.should == 1
      
      TestModule::TestModel.define_index do; end
      
      ThinkingSphinx.indexed_models.select { |model|
        model == "TestModule::TestModel"
      }.length.should == 1
    end
    
    it "should add before_save and after_commit hooks to the model if delta indexing is enabled" do
      @index.stub_method(:delta? => true)
      
      TestModule::TestModel.define_index do; end
      
      TestModule::TestModel.should have_received(:before_save)
      TestModule::TestModel.should have_received(:after_commit)
    end
    
    it "should not add before_save and after_commit hooks to the model if delta indexing is disabled" do
      TestModule::TestModel.define_index do; end
      
      TestModule::TestModel.should_not have_received(:before_save)
      TestModule::TestModel.should_not have_received(:after_commit)
    end
    
    it "should add an after_destroy hook with delta indexing enabled" do
      @index.stub_method(:delta? => true)
      
      TestModule::TestModel.define_index do; end
      
      TestModule::TestModel.should have_received(:after_destroy).with(:toggle_deleted)
    end
    
    it "should add an after_destroy hook with delta indexing disabled" do
      TestModule::TestModel.define_index do; end
      
      TestModule::TestModel.should have_received(:after_destroy).with(:toggle_deleted)
    end
    
    it "should return the new index" do
      TestModule::TestModel.define_index.should == @index
    end
  end
  
  describe "to_crc32 method" do
    it "should return an integer" do
      Person.to_crc32.should be_a_kind_of(Integer)
    end
  end
  
  describe "in_core_index? method" do
    it "should return the model's corresponding search_for_id value" do
      Person.stub_method(:search_for_id => :searching_for_id)
      
      person = Person.find(:first)
      person.in_core_index?.should == :searching_for_id
      Person.should have_received(:search_for_id).with(person.id, "person_core")
    end
  end
  
  describe "toggle_deleted method" do
    before :each do
      @configuration = ThinkingSphinx::Configuration.stub_instance(
        :address  => "an address",
        :port     => 123
      )
      @client = Riddle::Client.stub_instance(:update => true)
      @person = Person.new
      
      ThinkingSphinx::Configuration.stub_method(:new => @configuration)
      Riddle::Client.stub_method(:new => @client)
      Person.indexes.each { |index| index.stub_method(:delta? => false) }
      @person.stub_method(:in_core_index? => true)
    end
    
    it "should create a client using the Configuration's address and port" do
      @person.toggle_deleted
      
      Riddle::Client.should have_received(:new).with(
        @configuration.address, @configuration.port
      )
    end
    
    it "should update the core index's deleted flag if in core index" do
      @person.toggle_deleted
      
      @client.should have_received(:update).with(
        "person_core", ["sphinx_deleted"], {@person.id => 1}
      )
    end
    
    it "shouldn't update the core index's deleted flag if the record isn't in it" do
      @person.stub_method(:in_core_index? => false)
      
      @person.toggle_deleted
      
      @client.should_not have_received(:update).with(
        "person_core", ["sphinx_deleted"], {@person.id => 1}
      )
    end
    
    it "should update the delta index's deleted flag if delta indexes are enabled and the instance's delta is true" do
      ThinkingSphinx.stub_method(:deltas_enabled? => true)
      Person.indexes.each { |index| index.stub_method(:delta? => true) }
      @person.delta = true
      
      @person.toggle_deleted
      
      @client.should have_received(:update).with(
        "person_delta", ["sphinx_deleted"], {@person.id => 1}
      )
    end
    
    it "should not update the delta index's deleted flag if delta indexes are enabled and the instance's delta is false" do
      ThinkingSphinx.stub_method(:deltas_enabled? => true)
      Person.indexes.each { |index| index.stub_method(:delta? => true) }
      @person.delta = false
      
      @person.toggle_deleted
      
      @client.should_not have_received(:update).with(
        "person_delta", ["sphinx_deleted"], {@person.id => 1}
      )
    end
    
    it "should not update the delta index's deleted flag if delta indexes are enabled and the instance's delta is equivalent to false" do
      ThinkingSphinx.stub_method(:deltas_enabled? => true)
      Person.indexes.each { |index| index.stub_method(:delta? => true) }
      @person.delta = 0

      @person.toggle_deleted

      @client.should_not have_received(:update).with(
        "person_delta", ["sphinx_deleted"], {@person.id => 1}
      )
    end

    it "shouldn't update the delta index if delta indexes are disabled" do
      ThinkingSphinx.stub_method(:deltas_enabled? => true)
      @person.toggle_deleted
      
      @client.should_not have_received(:update).with(
        "person_delta", ["sphinx_deleted"], {@person.id => 1}
      )
    end
    
    it "should not update the delta index if delta indexing is disabled" do
      ThinkingSphinx.stub_method(:deltas_enabled? => false)
      Person.indexes.each { |index| index.stub_method(:delta? => true) }
      @person.delta = true
      
      @person.toggle_deleted
      
      @client.should_not have_received(:update).with(
        "person_delta", ["sphinx_deleted"], {@person.id => 1}
      )
    end
    
    it "should not update either index if updates are disabled" do
      ThinkingSphinx.stub_methods(
        :updates_enabled? => false,
        :deltas_enabled   => true
      )
      Person.indexes.each { |index| index.stub_method(:delta? => true) }
      @person.delta = true
      
      @person.toggle_deleted
      
      @client.should_not have_received(:update)
    end
  end

  describe "indexes in the inheritance chain (STI)" do
    it "should hand defined indexes on a class down to its child classes" do
      Child.indexes.should include(*Person.indexes)
    end

    it "should allow associations to other STI models" do
      Child.indexes.last.link!
      sql = Child.indexes.last.to_sql.gsub('$start', '0').gsub('$end', '100')
      lambda { Child.connection.execute(sql) }.should_not raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
