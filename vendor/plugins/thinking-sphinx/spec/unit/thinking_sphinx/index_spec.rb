require 'spec/spec_helper'

describe ThinkingSphinx::Index do
  describe "to_config method" do
    before :each do
      @index = ThinkingSphinx::Index.new(Person)
      
      @index.stub_methods(
        :attributes => [
          ThinkingSphinx::Attribute.stub_instance(:to_sphinx_clause => "attr a"),
          ThinkingSphinx::Attribute.stub_instance(:to_sphinx_clause => "attr b")
        ],
        :link!              => true,
        :adapter            => :mysql,
        :to_sql_query_pre   => "sql_query_pre",
        :to_sql             => "SQL",
        :to_sql_query_range => "sql_query_range",
        :to_sql_query_info  => "sql_query_info",
        :delta?             => false
      )
      
      @database = {
        :host     => "localhost",
        :username => "username",
        :password => "blank",
        :database => "db"
      }
    end
    
    it "should call link!" do
      @index.to_config(Person, 0, @database, "utf-8", 0)
      
      @index.should have_received(:link!)
    end
    
    it "should raise an exception if the adapter isn't mysql or postgres" do
      @index.stub_method(:adapter => :sqlite)
      
      lambda { @index.to_config(Person, 0, @database, "utf-8", 0) }.should raise_error
    end
    
    it "should set the core source name to {model}_{index}_core" do
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /source person_0_core/
      )
    end
    
    it "should include the database config supplied" do
      conf = @index.to_config(Person, 0, @database, "utf-8", 0)
      conf.should match(/type\s+= mysql/)
      conf.should match(/sql_host\s+= localhost/)
      conf.should match(/sql_user\s+= username/)
      conf.should match(/sql_pass\s+= blank/)
      conf.should match(/sql_db\s+= db/)
    end
    
    it "should use 'user' if 'username' doesn't exist in database configuration" do
      conf = @index.to_config(Person, 0,
        @database.except(:username).merge(:user => "username"),
        "utf-8", 0
      )
      conf.should match(/sql_user\s+= username/)
    end
    
    it "should include the database socket if set" do
      conf = @index.to_config(Person, 0, @database.merge(:socket => "dbsocket"), "utf-8", 0)
      conf.should match(/sql_sock\s+= dbsocket/)
    end
    
    it "should not include the database socket if not set" do
      conf = @index.to_config(Person, 0, @database, "utf-8", 0)
      conf.should_not match(/sql_sock/)
    end
    
    it "should have a pre query 'SET NAMES utf8' if using mysql and utf8 charset" do
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /sql_query_pre\s+= SET NAMES utf8/
      )
      
      @index.stub_method(:delta? => true)
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /source person_0_delta.+sql_query_pre\s+= SET NAMES utf8/m
      )
      
      @index.stub_method(:delta? => false)
      @index.to_config(Person, 0, @database, "non-utf-8", 0).should_not match(
        /SET NAMES utf8/
      )
      
      @index.stub_method(:adapter => :postgres)
      @index.to_config(Person, 0, @database, "utf-8", 0).should_not match(
        /SET NAMES utf8/
      )
    end
    
    it "should use the pre query from the index" do
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /sql_query_pre\s+= sql_query_pre/
      )
    end
    
    it "should not set group_concat_max_len if not specified" do
      @index.to_config(Person, 0, @database, "utf-8", 0).should_not match(
        /group_concat_max_len/
      )
    end

    it "should set group_concat_max_len if specified" do
      @index.options.merge! :group_concat_max_len => 2056
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /sql_query_pre\s+= SET SESSION group_concat_max_len = 2056/
      )
      
      @index.stub_method(:delta? => true)
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /source person_0_delta.+sql_query_pre\s+= SET SESSION group_concat_max_len = 2056/m
      )
    end
    
    it "should use the main query from the index" do
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /sql_query\s+= SQL/
      )
    end
    
    it "should use the range query from the index" do
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /sql_query_range\s+= sql_query_range/
      )
    end

    it "should use the info query from the index" do
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /sql_query_info\s+= sql_query_info/
      )
    end
    
    it "should include the attribute sources" do
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /attr a\n\s+attr b/
      )
    end
    
    it "should add a delta index with name {model}_{index}_delta if requested" do
      @index.stub_method(:delta? => true)
      
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /source person_0_delta/
      )
    end
    
    it "should not add a delta index unless requested" do
      @index.to_config(Person, 0, @database, "utf-8", 0).should_not match(
        /source person_0_delta/
      )
    end
    
    it "should have the delta index inherit from the core index" do
      @index.stub_method(:delta? => true)
      
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /source person_0_delta : person_0_core/
      )
    end
    
    it "should redefine the main query for the delta index" do
      @index.stub_method(:delta? => true)
      
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /source person_0_delta.+sql_query\s+= SQL/m
      )
    end
    
    it "should redefine the range query for the delta index" do
      @index.stub_method(:delta? => true)
      
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /source person_0_delta.+sql_query_range\s+= sql_query_range/m
      )
    end
    
    it "should redefine the pre query for the delta index" do
      @index.stub_method(:delta? => true)
      
      @index.to_config(Person, 0, @database, "utf-8", 0).should match(
        /source person_0_delta.+sql_query_pre\s+=\s*\n/m
      )
    end
  end
  
  describe "to_sql method" do
    it "should include explicit groupings if requested" do
      @index = ThinkingSphinx::Index.new(Person)
      
      @index.groupings << "custom_sql"
      @index.to_sql.should match(/GROUP BY.+custom_sql/)
    end
  end
  
  describe "to_sql_query_range method" do
    before :each do
      @index = ThinkingSphinx::Index.new(Person)
    end
    
    it "should add COALESCE around MIN and MAX calls if using PostgreSQL" do
      @index.stub_method(:adapter => :postgres)
      
      @index.to_sql_query_range.should match(/COALESCE\(MIN.+COALESCE\(MAX/)
    end
    
    it "shouldn't add COALESCE if using MySQL" do
      @index.to_sql_query_range.should_not match(/COALESCE/)
    end
  end
  
  describe "prefix_fields method" do
    before :each do
      @index = ThinkingSphinx::Index.new(Person)
      
      @field_a = ThinkingSphinx::Field.stub_instance(:prefixes => true)
      @field_b = ThinkingSphinx::Field.stub_instance(:prefixes => false)
      @field_c = ThinkingSphinx::Field.stub_instance(:prefixes => true)
      
      @index.fields = [@field_a, @field_b, @field_c]
    end
    
    it "should return fields that are flagged as prefixed" do
      @index.prefix_fields.should include(@field_a)
      @index.prefix_fields.should include(@field_c)
    end
    
    it "should not return fields that aren't flagged as prefixed" do
      @index.prefix_fields.should_not include(@field_b)
    end
  end
  
  describe "infix_fields method" do
    before :each do
      @index = ThinkingSphinx::Index.new(Person)
      
      @field_a = ThinkingSphinx::Field.stub_instance(:infixes => true)
      @field_b = ThinkingSphinx::Field.stub_instance(:infixes => false)
      @field_c = ThinkingSphinx::Field.stub_instance(:infixes => true)
      
      @index.fields = [@field_a, @field_b, @field_c]
    end
    
    it "should return fields that are flagged as infixed" do
      @index.infix_fields.should include(@field_a)
      @index.infix_fields.should include(@field_c)
    end
    
    it "should not return fields that aren't flagged as infixed" do
      @index.infix_fields.should_not include(@field_b)
    end
  end
  
  describe "empty? method" do
    before :each do
      @index = ThinkingSphinx::Index.new(Contact)
      config = ThinkingSphinx::Configuration.new
      
      `mkdir -p #{config.searchd_file_path}`
      @file_path = "#{config.searchd_file_path}/#{@index.name}_core.spa"
    end
    
    after :each do
      FileUtils.rm(@file_path, :force => true)
    end
    
    it "should return true if the core index files are empty" do
      `touch #{@file_path}`
      @index.should be_empty
    end
    
    it "should return true if the core index files don't exist" do
      @index.should be_empty
    end
    
    it "should return false if the core index files aren't empty" do
      `echo 'a' > #{@file_path}`
      @index.should_not be_empty
    end
    
    it "should check the delta files if specified" do
      delta_path = @file_path.gsub(/_core.spa$/, '_delta.spa')
      
      @index.should be_empty(:delta)
      `echo 'a' > #{delta_path}`
      @index.should_not be_empty(:delta)
      
      FileUtils.rm(delta_path)
    end
  end
  
  describe "initialize_from_builder method" do
    it "should copy groupings across from the builder to the index" do
      @index = ThinkingSphinx::Index.new(Person) do
        group_by "custom_grouping"
      end
      @index.groupings.should include("custom_grouping")
    end
  end
end