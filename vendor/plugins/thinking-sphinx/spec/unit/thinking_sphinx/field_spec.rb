require 'spec/spec_helper'

describe ThinkingSphinx::Field do
  describe '#initialize' do
    it 'raises if no columns are provided so that configuration errors are easier to track down' do
      lambda {
        ThinkingSphinx::Field.new([])
      }.should raise_error(RuntimeError)
    end

    it 'raises if an element of the columns param is an integer - as happens when you use id instead of :id - so that configuration errors are easier to track down' do
      lambda {
        ThinkingSphinx::Field.new([1234])
      }.should raise_error(RuntimeError)
    end
  end
  
  describe "to_select_sql method with MySQL" do
    before :each do
      @index = Person.indexes.first
      @index.link!
    end
    
    it "should concat with spaces if there are multiple columns" do
      @index.fields.first.to_select_sql.should match(/CONCAT_WS\(' ', /)
    end
    
    it "should concat with spaces if a column has more than one association" do
      @index.fields[1].to_select_sql.should match(/CONCAT_WS\(' ', /)
    end
    
    it "should group if any association for any column is a has_many or has_and_belongs_to_many" do
      @index.fields[2].to_select_sql.should match(/GROUP_CONCAT/)
    end
  end
  
  describe "to_select_sql method with PostgreSQL" do
    before :each do
      @index = Person.indexes.first
      Person.connection.class.stub_method(
        :name => "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
      )
      @index.link!
    end
    
    it "should concat with spaces if there are multiple columns" do
      @index.fields.first.to_select_sql.should match(/|| ' ' ||/)
    end
    
    it "should concat with spaces if a column has more than one association" do
      @index.fields[1].to_select_sql.should match(/|| ' ' ||/)
    end
    
    it "should group if any association for any column is a has_many or has_and_belongs_to_many" do
      @index.fields[2].to_select_sql.should match(/array_to_string\(array_accum\(/)
    end
  end
  
  describe "to_group_sql method" do
    before :each do
      @field = ThinkingSphinx::Field.new([Object.stub_instance(:__stack => [])])
      @field.stub_methods(:is_many? => false)
      
      ThinkingSphinx.stub_method(:use_group_by_shortcut? => false)
    end
    
    it "should return nil if is_many?" do
      @field.stub_method(:is_many? => true)
      
      @field.to_group_sql.should be_nil
    end
    
    it "should return nil if group_by shortcut is allowed" do
      ThinkingSphinx.stub_method(:use_group_by_shortcut? => true)
      
      @field.to_group_sql.should be_nil
    end
    
    it "should return an array if neither is_many? or shortcut allowed" do
      @field.stub_method(:column_with_prefix => 'hello')
      @field.to_group_sql.should be_a_kind_of(Array)
    end
  end
  
  describe "unique_name method" do
    before :each do
      @field = ThinkingSphinx::Field.new [
        Object.stub_instance(:__stack => [], :__name => "col_name")
      ]
    end
    
    it "should use the alias if there is one" do
      @field.alias = "alias"
      @field.unique_name.should == "alias"
    end
    
    it "should use the alias if there's multiple columns" do
      @field.columns << Object.stub_instance(:__stack => [], :__name => "col_name")
      @field.unique_name.should be_nil
      
      @field.alias = "alias"
      @field.unique_name.should == "alias"
    end
    
    it "should use the column name if there's no alias and just one column" do
      @field.unique_name.should == "col_name"
    end
  end

  describe "prefixes method" do
    it "should default to false" do
      @field = ThinkingSphinx::Field.new([Object.stub_instance(:__stack => [])])
      @field.prefixes.should be_false
    end
    
    it "should be true if the corresponding option is set" do
      @field = ThinkingSphinx::Field.new(
        [Object.stub_instance(:__stack => [])], :prefixes => true
      )
      @field.prefixes.should be_true
    end
  end
  
  describe "infixes method" do
    it "should default to false" do
      @field = ThinkingSphinx::Field.new([Object.stub_instance(:__stack => [])])
      @field.infixes.should be_false
    end
    
    it "should be true if the corresponding option is set" do
      @field = ThinkingSphinx::Field.new(
        [Object.stub_instance(:__stack => [])], :infixes => true
      )
      @field.infixes.should be_true
    end
  end
  
  describe "quote_column_name method" do
    it "should delegate the call to the model's connection" do
      @field = ThinkingSphinx::Field.new [
        ThinkingSphinx::Index::FauxColumn.new(:col_name)
      ]
      @field.model = Person
      Person.connection.stub_method(:quote_column_name => "quoted!")
      
      @field.send(:quote_column, "blah").should == "quoted!"
    end
  end
  
  describe "column_with_prefix method" do
    before :each do
      @field = ThinkingSphinx::Field.new [
        ThinkingSphinx::Index::FauxColumn.new(:col_name)
      ]
      @field.columns.each { |col| @field.associations[col] = [] }
      @field.model = Person
      
      @first_join   = Object.stub_instance(:aliased_table_name => "tabular")
      @second_join  = Object.stub_instance(:aliased_table_name => "data")
      
      @first_assoc  = ThinkingSphinx::Association.stub_instance(
        :join => @first_join, :has_column? => true
      )
      @second_assoc = ThinkingSphinx::Association.stub_instance(
        :join => @second_join, :has_column? => true
      )
    end
    
    it "should return the column name if the column is a string" do
      @field.columns = [ThinkingSphinx::Index::FauxColumn.new("string")]
      @field.send(:column_with_prefix, @field.columns.first).should == "string"
    end
    
    it "should return the column with model's table prefix if there's no associations for the column" do
      @field.send(:column_with_prefix, @field.columns.first).should == "`people`.`col_name`"
    end
    
    it "should return the column with its join table prefix if an association exists" do
      column = @field.columns.first
      @field.associations[column] = [@first_assoc]
      @field.send(:column_with_prefix, column).should == "`tabular`.`col_name`"
    end
    
    it "should return multiple columns concatenated if more than one association exists" do
      column = @field.columns.first
      @field.associations[column] = [@first_assoc, @second_assoc]
      @field.send(:column_with_prefix, column).should == "`tabular`.`col_name`, `data`.`col_name`"
    end
  end
  
  describe "is_many? method" do
    before :each do
      @assoc_a = Object.stub_instance(:is_many? => true)
      @assoc_b = Object.stub_instance(:is_many? => true)
      @assoc_c = Object.stub_instance(:is_many? => true)
      
      @field = ThinkingSphinx::Field.new(
        [ThinkingSphinx::Index::FauxColumn.new(:col_name)]
      )
      @field.associations = {
        :a => @assoc_a, :b => @assoc_b, :c => @assoc_c
      }
    end
    
    it "should return true if all associations return true to is_many?" do
      @field.send(:is_many?).should be_true
    end
    
    it "should return true if one association returns true to is_many?" do
      @assoc_b.stub_method(:is_many? => false)
      @assoc_c.stub_method(:is_many? => false)
      
      @field.send(:is_many?).should be_true
    end
    
    it "should return false if all associations return false to is_many?" do
      @assoc_a.stub_method(:is_many? => false)
      @assoc_b.stub_method(:is_many? => false)
      @assoc_c.stub_method(:is_many? => false)
      
      @field.send(:is_many?).should be_false
    end
  end
end
