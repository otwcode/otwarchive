require 'spec/spec_helper'

describe ThinkingSphinx::Configuration do
  describe "environment class method" do
    before :each do
      ThinkingSphinx::Configuration.send(:class_variable_set, :@@environment, nil)
      
      ENV["RAILS_ENV"]  = nil
      ENV["MERB_ENV"]   = nil
    end
    
    it "should use the Merb environment value if set" do
      unless defined?(Merb)
        module Merb; end
      end
      
      ThinkingSphinx::Configuration.stub_method(:defined? => true)
      ENV["MERB_ENV"] = "merb_production"
      ThinkingSphinx::Configuration.environment.should == "merb_production"
      
      Object.send(:remove_const, :Merb)
    end
    
    it "should use the Rails environment value if set" do
      ENV["RAILS_ENV"] = "rails_production"
      ThinkingSphinx::Configuration.environment.should == "rails_production"
    end
    
    it "should default to development" do
      ThinkingSphinx::Configuration.environment.should == "development"
    end
  end
  
  describe "environment instance method" do
    it "should return the class method" do
      ThinkingSphinx::Configuration.stub_method(:environment => "spec")
      ThinkingSphinx::Configuration.new.environment.should == "spec"
      ThinkingSphinx::Configuration.should have_received(:environment)
    end    
  end
  
  describe "build method" do
    before :each do
      @config = ThinkingSphinx::Configuration.new
      
      @config.stub_methods(
        :load_models                  => "",
        :core_index_for_model         => "",
        :delta_index_for_model        => "",
        :distributed_index_for_model  => "",
        :create_array_accum           => true
      )
      
      ThinkingSphinx.stub_method :indexed_models => ["Person", "Friendship"]
      YAML.stub_method(:load => {
        :development => {
          "option" => "value"
        }
      })
      
      @person_index_a = ThinkingSphinx::Index.stub_instance(
        :to_config => "",   :adapter => :mysql, :delta? => false,
        :name => "person",  :model => Person
      )
      @person_index_b = ThinkingSphinx::Index.stub_instance(
        :to_config => "",   :adapter => :mysql, :delta? => false,
        :name => "person",  :model => Person
      )
      @friendship_index_a = ThinkingSphinx::Index.stub_instance(
        :to_config => "",       :adapter => :mysql, :delta? => false,
        :name => "friendship",  :model => Friendship
      )
      
      Person.stub_method(:indexes => [@person_index_a, @person_index_b])
      Friendship.stub_method(:indexes => [@friendship_index_a])
      
      FileUtils.mkdir_p "#{@config.app_root}/config"
      FileUtils.touch   "#{@config.app_root}/config/database.yml"
    end
    
    after :each do
      ThinkingSphinx.unstub_method :indexed_models
      YAML.unstub_method :load
      
      Person.unstub_method      :indexes
      Friendship.unstub_method  :indexes
      # 
      # FileUtils.rm_rf "#{@config.app_root}/config"
    end
    
    # it "should load the models" do
    #   @config.build
    #   
    #   @config.should have_received(:load_models)
    # end
    
    it "should load in the database YAML configuration" do
      @config.build
      
      YAML.should have_received(:load)
    end
    
    it "should set the mem limit based on the configuration" do
      @config.build
      
      file = open(@config.config_file) { |f| f.read }
      file.should match(/mem_limit\s+= #{@config.mem_limit}/)
    end
    
    it "should use the configuration port" do
      @config.build
      
      file = open(@config.config_file) { |f| f.read }
      file.should match(/port\s+= #{@config.port}/)
    end
    
    it "should use the configuration's log file locations" do
      @config.build
      
      file = open(@config.config_file) { |f| f.read }
      file.should match(/log\s+= #{@config.searchd_log_file}/)
      file.should match(/query_log\s+= #{@config.query_log_file}/)
    end
    
    it "should use the configuration's pid file location" do
      @config.build
      
      file = open(@config.config_file) { |f| f.read }
      file.should match(/pid_file\s+= #{@config.pid_file}/)
    end
    
    it "should set max matches from configuration" do
      @config.build
      
      file = open(@config.config_file) { |f| f.read }
      file.should match(/max_matches\s+= #{@config.max_matches}/)
    end
    
    it "should request configuration for each index for each model" do
      @config.build
      
      @person_index_a.should have_received(:to_config).with(
        Person, 0, {:option => "value"}, @config.charset_type, 0
      )
      @person_index_b.should have_received(:to_config).with(
        Person, 1, {:option => "value"}, @config.charset_type, 0
      )
      @friendship_index_a.should have_received(:to_config).with(
        Friendship, 0, {:option => "value"}, @config.charset_type, 1
      )
    end
    
    it "should call create_array_accum if any index uses postgres" do
      @person_index_a.stub_method(:adapter => :postgres)
      
      @config.build
      
      @config.should have_received(:create_array_accum)
    end
    
    it "should not call create_array_accum if no index uses postgres" do
      @config.build
      
      @config.should_not have_received(:create_array_accum)
    end
    
    it "should call core_index_for_model for each model" do
      @config.build
      
      @config.should have_received(:core_index_for_model).with(
        Person, "source = person_0_core\nsource = person_1_core"
      )
      @config.should have_received(:core_index_for_model).with(
        Friendship, "source = friendship_0_core"
      )
    end
    
    it "should call delta_index_for_model for each model if any index has a delta" do
      @person_index_b.stub_method(:delta? => true)
      
      @config.build
      
      @config.should have_received(:delta_index_for_model).with(
        Person, "source = person_1_delta"
      )
    end
    
    it "should not call delta_index_for_model for each model if no indexes have deltas" do
      @config.build
      
      @config.should_not have_received(:delta_index_for_model)
    end
    
    it "should call distributed_index_for_model for each model" do
      @config.build
      
      @config.should have_received(:distributed_index_for_model).with(Person)
      @config.should have_received(:distributed_index_for_model).with(Friendship)
    end
  end
  
  describe "load_models method" do
    it "should have some specs"
  end
  
  describe "parse_config method" do
    before :each do
      @settings = {
        "development" => {
          "config_file"       => "tmp/config/development.sphinx.conf",
          "searchd_log_file"  => "searchd_log_file.log",
          "query_log_file"    => "query_log_file.log",
          "pid_file"          => "pid_file.pid",
          "searchd_file_path" => "searchd/file/path",
          "address"           => "127.0.0.1",
          "port"              => 3333,
          "allow_star"        => true,
          "min_prefix_len"    => 2,
          "min_infix_len"     => 3,
          "mem_limit"         => "128M",
          "max_matches"       => 1001,
          "morphology"        => "stem_ru",
          "charset_type"      => "latin1",
          "charset_table"     => "table",
          "ignore_chars"      => "e"
        }
      }
      
      open("#{RAILS_ROOT}/config/sphinx.yml", "w") do |f|
        f.write  YAML.dump(@settings)
      end
    end
    
    it "should use the accessors to set the configuration values" do
      config = ThinkingSphinx::Configuration.new
      @settings["development"].each do |key, value|
        config.send(key).should == value
      end
    end
    
    after :each do
      FileUtils.rm "#{RAILS_ROOT}/config/sphinx.yml"
    end
  end
  
  describe "core_index_for_model method" do
    before :each do
      @config = ThinkingSphinx::Configuration.new
      @model  = Person
    end
    
    it "should take its name from the model, with _core appended" do
      @config.send(:core_index_for_model, @model, "my sources").should match(
        /index person_core/
      )
    end
    
    it "should set the path to follow the name" do
      @config.searchd_file_path = "/my/file/path"
      @config.send(:core_index_for_model, @model, "my sources").should match(
        /path = \/my\/file\/path\/person_core/
      )
    end
    
    it "should include the charset type setting" do
      @config.charset_type = "specchars"
      @config.send(:core_index_for_model, @model, "my sources").should match(
        /charset_type = specchars/
      )
    end
    
    it "should include the morphology setting if it isn't blank" do
      @config.morphology = "morph"
      @config.send(:core_index_for_model, @model, "my sources").should match(
        /morphology\s+= morph/
      )
    end
    
    it "should not include the morphology setting if it is blank" do
      @config.morphology = nil
      @config.send(:core_index_for_model, @model, "my sources").should_not match(
        /morphology\s+=/
      )
      
      @config.morphology = ""
      @config.send(:core_index_for_model, @model, "my sources").should_not match(
        /morphology\s+=/
      )
    end
    
    it "should include the charset_table value if it isn't nil" do
      @config.charset_table = "table_chars"
      @config.send(:core_index_for_model, @model, "my sources").should match(
        /charset_table\s+= table_chars/
      )
    end
    
    it "should not set the charset_table value if it is nil" do
      @config.charset_table = nil
      @config.send(:core_index_for_model, @model, "my sources").should_not match(
        /charset_table\s+=/
      )      
    end
    
    it "should set the ignore_chars value if it isn't nil" do
      @config.ignore_chars = "ignorable"
      @config.send(:core_index_for_model, @model, "my sources").should match(
        /ignore_chars\s+= ignorable/
      )
    end
    
    it "should not set the ignore_chars value if it is nil" do
      @config.ignore_chars = nil
      @config.send(:core_index_for_model, @model, "my sources").should_not match(
        /ignore_chars\s+=/
      )
    end
    
    it "should include the star-related settings when allow_star is true" do
      @config.allow_star      = true
      @config.min_prefix_len  = 1
      text =  @config.send(:core_index_for_model, @model, "my sources")
      
      text.should match(/enable_star\s+= 1/)
      text.should match(/min_prefix_len\s+= 1/)
      # text.should match(/min_infix_len\s+= 1/)
    end
    
    it "should use the configuration's infix and prefix length values if set" do
      @config.allow_star     = true
      @config.min_prefix_len = 3
      @config.min_infix_len  = 2
      text =  @config.send(:core_index_for_model, @model, "my sources")
      
      text.should match(/min_prefix_len\s+= 3/)
      # text.should match(/min_infix_len\s+= 2/)
    end
    
    it "should not include the star-related settings when allow_star is false" do
      @config.allow_star = false
      text =  @config.send(:core_index_for_model, @model, "my sources")
      
      text.should_not match(/enable_star\s+=/)
      text.should_not match(/min_prefix_len\s+=/)
      text.should_not match(/min_infix_len\s+=/)
    end
    
    it "should set prefix_fields if any fields are flagged explicitly" do
      @model.indexes.first.stub_methods(
        :prefix_fields => [
          ThinkingSphinx::Field.stub_instance(:unique_name => "a"),
          ThinkingSphinx::Field.stub_instance(:unique_name => "b"),
          ThinkingSphinx::Field.stub_instance(:unique_name => "c")
        ],
        :infix_fields  => [
          ThinkingSphinx::Field.stub_instance(:unique_name => "d"),
          ThinkingSphinx::Field.stub_instance(:unique_name => "e"),
          ThinkingSphinx::Field.stub_instance(:unique_name => "f")
        ]
      )
      
      @config.send(:core_index_for_model, @model, "my sources").should match(
        /prefix_fields\s+= a, b, c/
      )
    end
    
    it "shouldn't set prefix_fields if none are flagged explicitly" do
      @config.send(:core_index_for_model, @model, "my sources").should_not match(
        /prefix_fields\s+=/
      )
    end
    
    it "should set infix_fields if any fields are flagged explicitly" do
      @model.indexes.first.stub_methods(
        :prefix_fields => [
          ThinkingSphinx::Field.stub_instance(:unique_name => "a"),
          ThinkingSphinx::Field.stub_instance(:unique_name => "b"),
          ThinkingSphinx::Field.stub_instance(:unique_name => "c")
        ],
        :infix_fields  => [
          ThinkingSphinx::Field.stub_instance(:unique_name => "d"),
          ThinkingSphinx::Field.stub_instance(:unique_name => "e"),
          ThinkingSphinx::Field.stub_instance(:unique_name => "f")
        ]
      )
      
      @config.send(:core_index_for_model, @model, "my sources").should match(
        /infix_fields\s+= d, e, f/
      )
    end
    
    it "shouldn't set infix_fields if none are flagged explicitly" do
      @config.send(:core_index_for_model, @model, "my sources").should_not match(
        /infix_fields\s+=/
      )
    end

    it "should include html_strip if value is set" do
      @config.html_strip = 1
      text = @config.send(:core_index_for_model, @model, "my sources")
      text.should match(/html_strip\s+= 1/)
    end

    it "shouldn't include html_strip if value is not set" do
      text = @config.send(:core_index_for_model, @model, "my sources")
      text.should_not match(/html_strip/)
    end

    it "should include html_remove_elements if values are set" do
      @config.html_remove_elements = 'script'
      text = @config.send(:core_index_for_model, @model, "my sources")
      text.should match(/html_remove_elements\s+= script/)
    end

    it "shouldn't include html_remove_elements if no values are set" do
      text = @config.send(:core_index_for_model, @model, "my sources")
      text.should_not match(/html_remove_elements/)
    end
  end
  
  describe "delta_index_for_model method" do
    before :each do
      @config = ThinkingSphinx::Configuration.new
      @model  = Person
    end
    
    it "should take its name from the model, with _delta appended" do
      @config.send(:delta_index_for_model, @model, "delta_sources").should match(
        /index person_delta/
      )
    end
    
    it "should inherit from the equivalent core index" do
      @config.send(:delta_index_for_model, @model, "delta_sources").should match(
        /index person_delta : person_core/
      )
    end
    
    it "should set the path to follow the name" do
      @config.searchd_file_path = "/my/file/path"
      @config.send(:delta_index_for_model, @model, "delta_sources").should match(
        /path = \/my\/file\/path\/person_delta/
      )
    end
  end
  
  describe "distributed_index_for_model method" do
    before :each do
      @config = ThinkingSphinx::Configuration.new
      @model  = Person
    end
    
    it "should take its name from the model" do
      @config.send(:distributed_index_for_model, @model).should match(
        /index person/
      )
    end
    
    it "should have a type of distributed" do
      @config.send(:distributed_index_for_model, @model).should match(
        /type = distributed/
      )
    end
    
    it "should include the core as a local source" do
      @config.send(:distributed_index_for_model, @model).should match(
        /local = person_core/
      )
    end
    
    it "should only include the delta as a local source if an index is flagged to be delta" do
      @config.send(:distributed_index_for_model, @model).should_not match(
        /local = person_delta/
      )
      
      @model.indexes.first.stub_method(:delta? => true)
      @config.send(:distributed_index_for_model, @model).should match(
        /local = person_delta/
      )
    end
    
    it "should handle namespaced models correctly" do
      Person.stub_method(:name => "Namespaced::Model")
      
      @config.send(:distributed_index_for_model, @model).should match(
        /index namespaced_model/
      )
    end
  end
  
  describe "create_array_accum method" do
    it "should create the array_accum method on PostgreSQL"
  end
end