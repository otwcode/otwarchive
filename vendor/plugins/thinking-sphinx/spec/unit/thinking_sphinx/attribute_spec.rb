require 'spec/spec_helper'

describe ThinkingSphinx::Attribute do
  describe '#initialize' do
    it 'raises if no columns are provided so that configuration errors are easier to track down' do
      lambda {
        ThinkingSphinx::Attribute.new([])
      }.should raise_error(RuntimeError)
    end

    it 'raises if an element of the columns param is an integer - as happens when you use id instead of :id - so that configuration errors are easier to track down' do
      lambda {
        ThinkingSphinx::Attribute.new([1234])
      }.should raise_error(RuntimeError)
    end
  end
  
  describe "to_select_sql method with MySQL" do
    before :each do
      @index = Person.indexes.first
      @index.link!
    end
    
    it "should concat with spaces if there's more than one non-integer column" do
      @index.attributes[0].to_select_sql.should match(/CONCAT_WS\(' ', /)
    end
    
    it "should concat with spaces if there's more than one association for a non-integer column" do
      @index.attributes[1].to_select_sql.should match(/CONCAT_WS\(' ', /)
    end
    
    it "should concat with commas if there's multiple integer columns" do
      @index.attributes[2].to_select_sql.should match(/CONCAT_WS\(',', /)
    end
    
    it "should concat with commas if there's more than one association for an integer column" do
      @index.attributes[3].to_select_sql.should match(/CONCAT_WS\(',', /)
    end
    
    it "should group with spaces if there's string columns from a has_many or has_and_belongs_to_many association" do
      @index.attributes[4].to_select_sql.should match(/GROUP_CONCAT\(.+ SEPARATOR ' '\)/)
    end
    
    it "should group with commas if there's integer columns from a has_many or has_and_belongs_to_many association" do
      @index.attributes[5].to_select_sql.should match(/GROUP_CONCAT\(.+ SEPARATOR ','\)/)
    end
    
    it "should convert datetime values to timestamps" do
      @index.attributes[6].to_select_sql.should match(/UNIX_TIMESTAMP/)
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
    
    it "should concat with spaces if there's more than one non-integer column" do
      @index.attributes[0].to_select_sql.should match(/|| ' ' ||/)
    end
    
    it "should concat with spaces if there's more than one association for a non-integer column" do
      @index.attributes[1].to_select_sql.should match(/|| ' ' ||/)
    end
    
    it "should concat with commas if there's multiple integer columns" do
      @index.attributes[2].to_select_sql.should match(/|| ',' ||/)
    end
    
    it "should concat with commas if there's more than one association for an integer column" do
      @index.attributes[3].to_select_sql.should match(/|| ',' ||/)
    end
    
    it "should group with spaces if there's string columns from a has_many or has_and_belongs_to_many association" do
      @index.attributes[4].to_select_sql.should match(/array_to_string\(array_accum\(.+, ' '\)/)
    end
    
    it "should group with commas if there's integer columns from a has_many or has_and_belongs_to_many association" do
      @index.attributes[5].to_select_sql.should match(/array_to_string\(array_accum\(.+, ','\)/)
    end
  end
  
  describe "to_group_sql method" do
    before :each do
      @attribute = ThinkingSphinx::Attribute.new([Object.stub_instance(:__stack => [])])
      @attribute.stub_method(:is_many? => false, :is_string? => false)
      
      ThinkingSphinx.stub_method(:use_group_by_shortcut? => false)
    end
    
    it "should return nil if is_many?" do
      @attribute.stub_method(:is_many? => true)
      
      @attribute.to_group_sql.should be_nil
    end
    
    it "should return nil if is_string?" do
      @attribute.stub_method(:is_string? => true)
      
      @attribute.to_group_sql.should be_nil
    end
    
    it "should return nil if group_by shortcut is allowed" do
      ThinkingSphinx.stub_method(:use_group_by_shortcut? => true)
      
      @attribute.to_group_sql.should be_nil
    end
    
    it "should return an array if neither is_many? or shortcut allowed" do
      @attribute.stub_method(:column_with_prefix => 'hello')
      @attribute.to_group_sql.should be_a_kind_of(Array)
    end
    
    after :each do
      ThinkingSphinx.unstub_method(:use_group_by_shortcut?)
    end
  end
  
  describe "to_sphinx_clause method" do
    before :each do
      @attribute = ThinkingSphinx::Attribute.new [Object.stub_instance(:__stack => [])]
      @attribute.stub_method(:unique_name => "unique name")
    end
    
    it "should use sql_attr_multi syntax for MVA attributes" do
      @attribute.stub_method(:type => :multi)
      @attribute.to_sphinx_clause.should match(/^sql_attr_multi\s+= uint unique name from field$/)
    end
    
    it "should use sql_attr_timestamp syntax for datetime values" do
      @attribute.stub_method(:type => :datetime)
      @attribute.to_sphinx_clause.should match(/^sql_attr_timestamp\s+= unique name$/)
    end
    
    it "should use sql_attr_str2ordinal for string values" do
      @attribute.stub_method(:type => :string)
      @attribute.to_sphinx_clause.should match(/^sql_attr_str2ordinal\s+= unique name$/)
    end
    
    it "should use sql_attr_float for float values" do
      @attribute.stub_method(:type => :float)
      @attribute.to_sphinx_clause.should match(/^sql_attr_float\s+= unique name$/)
    end
    
    it "should use sql_attr_bool for boolean values" do
      @attribute.stub_method(:type => :boolean)
      @attribute.to_sphinx_clause.should match(/^sql_attr_bool\s+= unique name$/)
    end
    
    it "should use sql_attr_uint for integer values" do
      @attribute.stub_method(:type => :integer)
      @attribute.to_sphinx_clause.should match(/^sql_attr_uint\s+= unique name$/)
    end
    
    it "should assume integer for any other types" do
      @attribute.stub_method(:type => :unknown)
      @attribute.to_sphinx_clause.should match(/^sql_attr_uint\s+= unique name$/)
    end
    
  end
  
  describe "unique_name method" do
    before :each do
      @attribute = ThinkingSphinx::Attribute.new [
        Object.stub_instance(:__stack => [], :__name => "col_name")
      ]
    end
    
    it "should use the alias if there is one" do
      @attribute.alias = "alias"
      @attribute.unique_name.should == "alias"
    end
    
    it "should use the alias if there's multiple columns" do
      @attribute.columns << Object.stub_instance(:__stack => [], :__name => "col_name")
      @attribute.unique_name.should be_nil
      
      @attribute.alias = "alias"
      @attribute.unique_name.should == "alias"
    end
    
    it "should use the column name if there's no alias and just one column" do
      @attribute.unique_name.should == "col_name"
    end
  end
  
  describe "column_with_prefix method" do
    before :each do
      @attribute = ThinkingSphinx::Attribute.new [
        ThinkingSphinx::Index::FauxColumn.new(:col_name)
      ]
      @attribute.columns.each { |col| @attribute.associations[col] = [] }
      @attribute.model = Person
      
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
      @attribute.columns = [ThinkingSphinx::Index::FauxColumn.new("string")]
      @attribute.send(:column_with_prefix, @attribute.columns.first).should == "string"
    end
    
    it "should return the column with model's table prefix if there's no associations for the column" do
      @attribute.send(:column_with_prefix, @attribute.columns.first).should == "`people`.`col_name`"
    end
    
    it "should return the column with its join table prefix if an association exists" do
      column = @attribute.columns.first
      @attribute.associations[column] = [@first_assoc]
      @attribute.send(:column_with_prefix, column).should == "`tabular`.`col_name`"
    end
    
    it "should return multiple columns concatenated if more than one association exists" do
      column = @attribute.columns.first
      @attribute.associations[column] = [@first_assoc, @second_assoc]
      @attribute.send(:column_with_prefix, column).should == "`tabular`.`col_name`, `data`.`col_name`"
    end
  end
  
  describe "is_many? method" do
    before :each do
      @assoc_a = Object.stub_instance(:is_many? => true)
      @assoc_b = Object.stub_instance(:is_many? => true)
      @assoc_c = Object.stub_instance(:is_many? => true)
      
      @attribute = ThinkingSphinx::Attribute.new(
        [ThinkingSphinx::Index::FauxColumn.new(:col_name)]
      )
      @attribute.associations = {
        :a => @assoc_a, :b => @assoc_b, :c => @assoc_c
      }
    end
    
    it "should return true if all associations return true to is_many?" do
      @attribute.send(:is_many?).should be_true
    end
    
    it "should return true if one association returns true to is_many?" do
      @assoc_b.stub_method(:is_many? => false)
      @assoc_c.stub_method(:is_many? => false)
      
      @attribute.send(:is_many?).should be_true
    end
    
    it "should return false if all associations return false to is_many?" do
      @assoc_a.stub_method(:is_many? => false)
      @assoc_b.stub_method(:is_many? => false)
      @assoc_c.stub_method(:is_many? => false)
      
      @attribute.send(:is_many?).should be_false
    end
  end
  
  describe "is_string? method" do
    before :each do
      @col_a = ThinkingSphinx::Index::FauxColumn.new("a")
      @col_b = ThinkingSphinx::Index::FauxColumn.new("b")
      @col_c = ThinkingSphinx::Index::FauxColumn.new("c")

      @attribute = ThinkingSphinx::Attribute.new(
        [@col_a, @col_b, @col_c]
      )
    end
    
    it "should return true if all columns return true to is_string?" do
      @attribute.send(:is_string?).should be_true
    end
    
    it "should return false if one column returns true to is_string?" do
      @col_a.send(:instance_variable_set, :@name, :a)
      @attribute.send(:is_string?).should be_false
    end
    
    it "should return false if all columns return false to is_string?" do
      @col_a.send(:instance_variable_set, :@name, :a)
      @col_b.send(:instance_variable_set, :@name, :b)
      @col_c.send(:instance_variable_set, :@name, :c)
      @attribute.send(:is_string?).should be_false
    end
  end
  
  describe "type method" do
    before :each do
      @column = ThinkingSphinx::Index::FauxColumn.new(:col_name)
      @attribute = ThinkingSphinx::Attribute.new([@column])
      @attribute.model = Person
      @attribute.stub_method(:is_many? => false)
    end
    
    it "should return :multi if is_many? is true" do
      @attribute.stub_method(:is_many? => true)
      @attribute.send(:type).should == :multi
    end
    
    it "should return :string if there's more than one association" do
      @attribute.associations = {:a => :assoc, :b => :assoc}
      @attribute.send(:type).should == :string
    end
    
    it "should return the column type from the database if not :multi or more than one association" do
      @column.send(:instance_variable_set, :@name, "birthday")
      @attribute.send(:type).should == :datetime
      
      @attribute.send(:instance_variable_set, :@type, nil)
      @column.send(:instance_variable_set, :@name, "first_name")
      @attribute.send(:type).should == :string
      
      @attribute.send(:instance_variable_set, :@type, nil)
      @column.send(:instance_variable_set, :@name, "id")
      @attribute.send(:type).should == :integer
    end
  end
  
  describe "all_ints? method" do
    it "should return true if all columns are integers" do
      attribute = ThinkingSphinx::Attribute.new(
        [ ThinkingSphinx::Index::FauxColumn.new(:id),
          ThinkingSphinx::Index::FauxColumn.new(:team_id) ]
      )
      attribute.model = Person
      attribute.columns.each { |col| attribute.associations[col] = [] }
      
      attribute.send(:all_ints?).should be_true
    end
    
    it "should return false if only some columns are integers" do
      attribute = ThinkingSphinx::Attribute.new(
        [ ThinkingSphinx::Index::FauxColumn.new(:id),
          ThinkingSphinx::Index::FauxColumn.new(:first_name) ]
      )
      attribute.model = Person
      attribute.columns.each { |col| attribute.associations[col] = [] }
      
      attribute.send(:all_ints?).should be_false
    end
    
    it "should return false if no columns are integers" do
      attribute = ThinkingSphinx::Attribute.new(
        [ ThinkingSphinx::Index::FauxColumn.new(:first_name),
          ThinkingSphinx::Index::FauxColumn.new(:last_name) ]
      )
      attribute.model = Person
      attribute.columns.each { |col| attribute.associations[col] = [] }
      
      attribute.send(:all_ints?).should be_false
    end
  end
end