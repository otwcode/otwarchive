require 'spec/spec_helper'

describe ThinkingSphinx::Index::FauxColumn do
  it "should use the last argument as the name, with preceeding ones going into the stack" do
    #
  end
  
  it "should access the name through __name" do
    #
  end
  
  it "should access the stack through __stack" do
    #
  end
  
  it "should return true from is_string? if the name is a string and the stack is empty" do
    #
  end
  
  describe "coerce class method" do
    before :each do
      @column = ThinkingSphinx::Index::FauxColumn.stub_instance
      ThinkingSphinx::Index::FauxColumn.stub_method(:new => @column)
    end
    
    it "should return a single faux column if passed a string" do
      ThinkingSphinx::Index::FauxColumn.coerce("string").should == @column
    end
    
    it "should return a single faux column if passed a symbol" do
      ThinkingSphinx::Index::FauxColumn.coerce(:string).should == @column
    end
    
    it "should return an array of faux columns if passed an array of strings" do
      ThinkingSphinx::Index::FauxColumn.coerce(["one", "two"]).should == [
        @column, @column
      ]
    end
    
    it "should return an array of faux columns if passed an array of symbols" do
      ThinkingSphinx::Index::FauxColumn.coerce([:one, :two]).should == [
        @column, @column
      ]
    end
  end
  
  describe "method_missing calls with no arguments" do
    it "should push any further method calls into name, and the old name goes into the stack" do
      #
    end
    
    it "should return itself" do
      #
    end
  end
  
  describe "method_missing calls with one argument" do
    it "should act as if calling method missing with method, then argument" do
      #
    end
  end
  
  describe "method_missing calls with more than one argument" do
    it "should return a collection of Faux Columns sharing the same stack, but with each argument as the name" do
      #
    end
  end
end