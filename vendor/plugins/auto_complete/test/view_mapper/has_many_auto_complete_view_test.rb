require 'helper'
require 'shoulda'
require 'mocha'
require 'rails_generator'
require 'rails_generator/scripts'
require 'rails_generator/scripts/generate'
require 'view_mapper'

def setup_test_table
  ActiveRecord::Base.connection.create_table :testies, :force => true do |table|
    table.column :first_name, :string
    table.column :last_name,  :string
    table.column :address,    :string
    table.column :some_flag,  :boolean
  end
end

def setup_test_model
  setup_test_table
  Object.send(:remove_const, "Testy") rescue nil
  Object.const_set("Testy", Class.new(ActiveRecord::Base))
  Object.const_get("Testy")
end

def setup_parent_test_model(create_foreign_key = true, child_belongs_to_parent = true)
  ActiveRecord::Base.connection.create_table :parents, :force => true do |table|
    table.column :name, :string
  end
  ActiveRecord::Base.connection.create_table :some_other_models, :force => true do |table|
    table.column :name,      :string
    table.column :parent_id, :integer
  end
  ActiveRecord::Base.connection.add_column :testies, :parent_id, :integer unless !create_foreign_key
  Object.send(:remove_const, "Parent") rescue nil
  Object.const_set("Parent", Class.new(ActiveRecord::Base))
  Object.send(:remove_const, "SomeOtherModel") rescue nil
  Object.const_set("SomeOtherModel", Class.new(ActiveRecord::Base))
  Parent.class_eval do
    has_many :testies
    has_many :some_other_model
    def testies_attributes=
      'fake'
    end
    def some_other_models_attributes=
      'fake'
    end
  end
  Testy.class_eval do
    belongs_to :parent unless !child_belongs_to_parent
  end
  SomeOtherModel.class_eval do
    belongs_to :parent
  end
  Object.const_get("Parent")
end

def setup_test_model_without_nested_attributes
  ActiveRecord::Base.connection.create_table :third_models, :force => true do |table|
    table.column :name, :string
  end
  Object.send(:remove_const, "ThirdModel") rescue nil
  Object.const_set("ThirdModel", Class.new(ActiveRecord::Base))
  Parent.class_eval do
    has_many :third_model
  end
end

class Rails::Generator::NamedBase
  public :attributes
end

def generator_cmd_line(gen, args, model)
  if gen == 'view_for'
    cmd_line = [model]
  else
    cmd_line = [model, 'first_name:string', 'last_name:string', 'address:string', 'some_flag:boolean']
  end
  (cmd_line << args).flatten
end

def generator_script_cmd_line(gen, args, model = 'testy')
  ([gen] << generator_cmd_line(gen, args, model)).flatten
end

def new_generator_for_test_model(gen, args, model = 'testy')
  Rails::Generator::Base.instance(gen, generator_cmd_line(gen, args, model))
end

def expect_no_actions
  Rails::Generator::Commands::Create.any_instance.expects(:directory).never
  Rails::Generator::Commands::Create.any_instance.expects(:template).never
  Rails::Generator::Commands::Create.any_instance.expects(:route_resources).never
  Rails::Generator::Commands::Create.any_instance.expects(:file).never
  Rails::Generator::Commands::Create.any_instance.expects(:route).never
  Rails::Generator::Commands::Create.any_instance.expects(:dependency).never
end

def expect_no_warnings
  Rails::Generator::Base.logger.expects(:error).never
  Rails::Generator::Base.logger.expects(:warning).never
  Rails::Generator::Base.logger.expects(:route).never
end

def stub_actions
  Rails::Generator::Commands::Create.any_instance.stubs(:directory)
  Rails::Generator::Commands::Create.any_instance.stubs(:template)
  Rails::Generator::Commands::Create.any_instance.stubs(:route_resources)
  Rails::Generator::Commands::Create.any_instance.stubs(:file)
  Rails::Generator::Commands::Create.any_instance.stubs(:route)
  Rails::Generator::Commands::Create.any_instance.stubs(:dependency)
end

def stub_warnings
  Rails::Generator::Base.logger.stubs(:error)
  Rails::Generator::Base.logger.stubs(:warning)
  Rails::Generator::Base.logger.stubs(:route)
end

def is_auto_complete_attribute?(model_name, text_field)
  (model_name == 'parent' && text_field == 'name') ||
  (model_name == 'testy' && (text_field == 'first_name' || text_field == 'last_name' || text_field == 'address'))
end

class HasManyAutoCompleteViewTest < Test::Unit::TestCase

  attr_reader :singular_name
  attr_reader :attributes
  attr_reader :plural_name
  attr_reader :child_models
  attr_reader :child_model
  attr_reader :class_name
  attr_reader :migration_name
  attr_reader :table_name
  attr_reader :options

  context "A view_for generator instantiated for a test model" do
    setup do
      setup_test_model
      setup_parent_test_model
      setup_test_model_without_nested_attributes
    end

    should "detect the existing child models when no child model is specified" do
      Rails::Generator::Base.logger.expects('warning').with('Model Parent does not accept nested attributes for model ThirdModel.')
      gen = new_generator_for_test_model('view_for', ['--view', 'has_many_auto_complete'], 'parent')
      child_models = gen.child_models
      assert_equal 2, child_models.size
      assert_equal 'SomeOtherModel', child_models[0].name
      assert_equal 'Testy',          child_models[1].name
      assert_equal [ 'name' ],       child_models[0].columns
      assert_equal [ 'first_name', 'last_name', 'address', 'some_flag' ], child_models[1].columns
    end

    should "find the specified valid child model if provided" do
      gen = new_generator_for_test_model('view_for', ['--view', 'has_many_auto_complete:testies'], 'parent')
      child_models = gen.child_models
      assert_equal 'Testy', gen.child_models[0].name
      assert_equal 1, gen.child_models.size
    end

    should "be able to parse two model names" do
      gen = new_generator_for_test_model('view_for', ['--view', 'has_many_auto_complete:testies,some_other_models'], 'parent')
      child_models = gen.child_models
      assert_equal 2, gen.child_models.size
      assert_equal 'Testy',          child_models[0].name
      assert_equal 'SomeOtherModel', child_models[1].name
      assert_equal [ 'name' ],       child_models[1].columns
      assert_equal [ 'first_name', 'last_name', 'address', 'some_flag' ], child_models[0].columns
    end

    should "return an error message with a bad child model param" do
      Rails::Generator::Base.logger.expects('error').with('Class \'blah\' does not exist or contains a syntax error and could not be loaded.')
      gen = new_generator_for_test_model('view_for', ['--view', 'has_many_auto_complete:blah'], 'parent')
      assert_equal [], gen.child_models
    end
  end

  context "A scaffold_for_view generator instantiated for a test model" do
    setup do
      setup_test_model
    end

    should "return a warning when run with scaffold_for_view when no has_many is specified and not run any actions" do
      expect_no_actions
      Rails::Generator::Base.logger.expects('error').with('No has_many association specified.')
      @generator_script = Rails::Generator::Scripts::Generate.new
      @generator_script.run(generator_script_cmd_line('scaffold_for_view', ['--view', 'has_many_auto_complete'], 'parent'))
    end
  end

  context "A test model with no has many associations" do
    setup do
      setup_test_model
    end

    should "return a error when run with view_for and not run any actions" do
      expect_no_actions
      Rails::Generator::Base.logger.expects('error').with('No has_many associations exist in class Testy.')
      @generator_script = Rails::Generator::Scripts::Generate.new
      @generator_script.run(generator_script_cmd_line('view_for', ['--view', 'has_many_auto_complete']))
    end

    should "return a error when run with scaffold_for_view and not run any actions" do
      expect_no_actions
      Rails::Generator::Base.logger.expects('error').with('No has_many association specified.')
      @generator_script = Rails::Generator::Scripts::Generate.new
      @generator_script.run(generator_script_cmd_line('scaffold_for_view', ['--view', 'has_many_auto_complete']))
    end
  end

  context "A test model with a has_many association for a model for which it does not accept nested attributes" do
    setup do
      setup_test_model
      setup_parent_test_model
      setup_test_model_without_nested_attributes
    end

    should "return a warning and stop when the problem model is specified" do
      expect_no_actions
      Rails::Generator::Base.logger.expects('warning').with('Model Parent does not accept nested attributes for model ThirdModel.')
      @generator_script = Rails::Generator::Scripts::Generate.new
      @generator_script.run(generator_script_cmd_line('view_for', ['--view', 'has_many_auto_complete:third_models'], 'parent'))
    end

    should "return a warning and not include the problem model when run with view_for but continue to run for other models" do
      stub_actions
      Rails::Generator::Base.logger.expects('warning').with('Model Parent does not accept nested attributes for model ThirdModel.')
      Rails::Generator::Commands::Create.any_instance.expects(:directory).with('app/controllers/')
      @generator_script = Rails::Generator::Scripts::Generate.new
      @generator_script.run(generator_script_cmd_line('view_for', ['--view', 'has_many_auto_complete'], 'parent'))
    end
  end

  context "A view_for generator instantiated for a test model with two has_many associations" do
    setup do
      setup_test_model
      setup_parent_test_model
      @gen = new_generator_for_test_model('view_for', ['--view', 'has_many_auto_complete'], 'parent')
    end

    should "return the proper source root" do
      assert_equal File.expand_path(File.dirname(__FILE__) + '/../../lib/view_mapper/templates'), ViewMapper::HasManyAutoCompleteView.source_root
    end

    view_for_templates = %w{ new edit show index }
    view_for_templates.each do | template |
      should "render the #{template} template as expected" do
        @attributes = @gen.attributes
        @singular_name = @gen.singular_name
        @plural_name = @gen.plural_name
        @child_models = @gen.child_models
        template_file = File.open(@gen.source_path("view_#{template}.html.erb"))
        result = ERB.new(template_file.read, nil, '-').result(binding)
        expected_file = File.open(File.join(File.dirname(__FILE__), "expected_templates/#{template}.html.erb"))
        assert_equal expected_file.read, result
      end
    end

    should "render the form partial as expected" do
      @attributes = @gen.attributes
      @singular_name = @gen.singular_name
      @plural_name = @gen.plural_name
      @child_models = @gen.child_models
      template_file = File.open(@gen.source_path("view_form.html.erb"))
      result = ERB.new(template_file.read, nil, '-').result(binding)
      expected_file = File.open(File.join(File.dirname(__FILE__), "expected_templates/_form.html.erb"))
      assert_equal expected_file.read, result
    end

    should "render the person partial as expected" do
      @child_model = @gen.child_models[1]
      template_file = File.open(@gen.source_path("view_child_form.html.erb"))
      result = ERB.new(template_file.read, nil, '-').result(binding)
      expected_file = File.open(File.join(File.dirname(__FILE__), "expected_templates/_person.html.erb"))
      assert_equal expected_file.read, result
    end
  end

  context "A scaffold_for_view generator instantiated for a test model with two has_many associations" do
    setup do
      setup_test_model
      setup_parent_test_model
      @gen = new_generator_for_test_model('scaffold_for_view', ['--view', 'has_many_auto_complete:some_other_models,testies'], 'parent')
    end

    should "find the parent model text field attributes" do
      assert_equal [
        {:model_name=>"parent", :text_field=>"first_name" },
        {:model_name=>"parent", :text_field=>"last_name" },
        {:model_name=>"parent", :text_field=>"address" }
      ], @gen.auto_complete_attributes_from_command_line
    end

    should "render the model template as expected" do
      @child_models = @gen.child_models
      @class_name = @gen.class_name
      @attributes = @gen.attributes
      template_file = File.open(@gen.source_path("model.rb"))
      result = ERB.new(template_file.read, nil, '-').result(binding)
      expected_file = File.open(File.join(File.dirname(__FILE__), "expected_templates/parent.rb"))
      assert_equal expected_file.read, result
    end

    should "render the migration template as expected" do
      @class_name = @gen.class_name
      @attributes = @gen.attributes
      @migration_name = 'CreateParents'
      @table_name = @gen.table_name
      @options = {}
      template_file = File.open(@gen.source_path("migration.rb"))
      result = ERB.new(template_file.read, nil, '-').result(binding)
      expected_file = File.open(File.join(File.dirname(__FILE__), "expected_templates/create_parents.rb"))
      assert_equal expected_file.read, result
    end
  end

  context "A Rails generator script" do
    setup do
      setup_test_model
      setup_parent_test_model
      @generator_script = Rails::Generator::Scripts::Generate.new
    end

    should "return a warning when run with view_for on an invalid child model and not run any actions" do
      expect_no_actions
      Rails::Generator::Base.logger.expects('error').with('Class \'blah\' does not exist or contains a syntax error and could not be loaded.')
      @generator_script = Rails::Generator::Scripts::Generate.new
      @generator_script.run(generator_script_cmd_line('view_for', ['--view', 'has_many_auto_complete:blah']))
    end

    should "create the correct manifest when the view_for generator is run with a valid child model" do

      expect_no_warnings

      directories = [
        'app/controllers/',
        'app/helpers/',
        'app/views/parents',
        'app/views/layouts/',
        'test/functional/',
        'test/unit/',
        'test/unit/helpers/',
        'public/stylesheets/'
      ].each { |path| Rails::Generator::Commands::Create.any_instance.expects(:directory).with(path) }

      templates = {
        'view_index.html.erb'  => 'app/views/parents/index.html.erb',
        'view_new.html.erb'    => 'app/views/parents/new.html.erb',
        'view_edit.html.erb'   => 'app/views/parents/edit.html.erb',
        'view_form.html.erb'   => 'app/views/parents/_form.html.erb',
        'layout.html.erb'      => 'app/views/layouts/parents.html.erb',
        'style.css'            => 'public/stylesheets/scaffold.css',
        'controller.rb'        => 'app/controllers/parents_controller.rb',
        'functional_test.rb'   => 'test/functional/parents_controller_test.rb',
        'helper.rb'            => 'app/helpers/parents_helper.rb',
        'helper_test.rb'       => 'test/unit/helpers/parents_helper_test.rb'
      }.each { |template, target| Rails::Generator::Commands::Create.any_instance.expects(:template).with(template, target) }

      testy_model_info = ViewMapper::ModelInfo.new('testy')
      parent_model_info = ViewMapper::ModelInfo.new('parent')
      ViewMapper::ModelInfo.stubs(:new).with('testy').returns(testy_model_info)
      ViewMapper::ModelInfo.stubs(:new).with('parent').returns(parent_model_info)
      Rails::Generator::Commands::Create.any_instance.expects(:template).with(
        'view_show.html.erb',
        'app/views/parents/show.html.erb',
        { :assigns => { :child_models => [ testy_model_info ] } }
      )
      Rails::Generator::Commands::Create.any_instance.expects(:template).with(
        'view_child_form.html.erb',
        'app/views/parents/_testy.html.erb',
        { :assigns => { :child_model => testy_model_info } }
      )
      Rails::Generator::Commands::Create.any_instance.expects(:file).with(
        'nested_attributes.js', 'public/javascripts/nested_attributes.js'
      )

      Rails::Generator::Commands::Create.any_instance.expects(:route).with(
        :path => 'auto_complete_for_parent_name',
        :name => 'connect',
        :action => 'auto_complete_for_parent_name',
        :controller => 'parents')
      Rails::Generator::Commands::Create.any_instance.expects(:route).with(
        :path => 'auto_complete_for_testy_first_name',
        :name => 'connect',
        :action => 'auto_complete_for_testy_first_name',
        :controller => 'parents')
      Rails::Generator::Commands::Create.any_instance.expects(:route).with(
        :path => 'auto_complete_for_testy_last_name',
        :name => 'connect',
        :action => 'auto_complete_for_testy_last_name',
        :controller => 'parents')
      Rails::Generator::Commands::Create.any_instance.expects(:route).with(
        :path => 'auto_complete_for_testy_address',
        :name => 'connect',
        :action => 'auto_complete_for_testy_address',
        :controller => 'parents')

      Rails::Generator::Commands::Create.any_instance.expects(:route_resources).with('parents')
      Rails::Generator::Commands::Create.any_instance.expects(:file).never
      Rails::Generator::Commands::Create.any_instance.expects(:dependency).never

      @generator_script.run(generator_script_cmd_line('view_for', ['--view', 'has_many_auto_complete:testies'], 'parent'))
    end

    should "create the correct manifest when the scaffold_for_view generator is run with a valid child model" do

      expect_no_warnings

      directories = [
        'app/models/',
        'app/controllers/',
        'app/helpers/',
        'app/views/parents',
        'app/views/layouts/',
        'test/functional/',
        'test/unit/',
        'test/unit/helpers/',
        'test/fixtures/',
        'public/stylesheets/'
      ].each { |path| Rails::Generator::Commands::Create.any_instance.expects(:directory).with(path) }

      templates = {
        'view_index.html.erb'  => 'app/views/parents/index.html.erb',
        'view_new.html.erb'    => 'app/views/parents/new.html.erb',
        'view_edit.html.erb'   => 'app/views/parents/edit.html.erb',
        'view_form.html.erb'   => 'app/views/parents/_form.html.erb',
        'layout.html.erb'      => 'app/views/layouts/parents.html.erb',
        'style.css'            => 'public/stylesheets/scaffold.css',
        'controller.rb'        => 'app/controllers/parents_controller.rb',
        'functional_test.rb'   => 'test/functional/parents_controller_test.rb',
        'helper.rb'            => 'app/helpers/parents_helper.rb',
        'helper_test.rb'       => 'test/unit/helpers/parents_helper_test.rb',
        'model.rb'            => 'app/models/parent.rb',
        'unit_test.rb'        => 'test/unit/parent_test.rb',
        'fixtures.yml'        => 'test/fixtures/parents.yml'
      }.each { |template, target| Rails::Generator::Commands::Create.any_instance.expects(:template).with(template, target) }

      testy_model_info = ViewMapper::ModelInfo.new('testy')
      parent_model_info = ViewMapper::ModelInfo.new('parent')
      ViewMapper::ModelInfo.stubs(:new).with('testy').returns(testy_model_info)
      ViewMapper::ModelInfo.stubs(:new).with('parent').returns(parent_model_info)
      Rails::Generator::Commands::Create.any_instance.expects(:template).with(
        'view_show.html.erb',
        'app/views/parents/show.html.erb',
        { :assigns => { :child_models => [ testy_model_info ] } }
      )
      Rails::Generator::Commands::Create.any_instance.expects(:template).with(
        'view_child_form.html.erb',
        'app/views/parents/_testy.html.erb',
        { :assigns => { :child_model => testy_model_info } }
      )
      Rails::Generator::Commands::Create.any_instance.expects(:file).with(
        'nested_attributes.js', 'public/javascripts/nested_attributes.js'
      )
      Rails::Generator::Commands::Create.any_instance.expects(:route_resources).with('parents')
      Rails::Generator::Commands::Create.any_instance.expects(:file).never
      Rails::Generator::Commands::Create.any_instance.expects(:dependency).never

      Rails::Generator::Commands::Create.any_instance.expects(:migration_template).with(
        'migration.rb',
        'db/migrate',
        :assigns => { :migration_name => "CreateParents" },
        :migration_file_name => "create_parents"
      )

      Rails::Generator::Commands::Create.any_instance.expects(:route).with(
        :path => 'auto_complete_for_parent_first_name',
        :name => 'connect',
        :action => 'auto_complete_for_parent_first_name',
        :controller => 'parents')
      Rails::Generator::Commands::Create.any_instance.expects(:route).with(
        :path => 'auto_complete_for_parent_last_name',
        :name => 'connect',
        :action => 'auto_complete_for_parent_last_name',
        :controller => 'parents')
      Rails::Generator::Commands::Create.any_instance.expects(:route).with(
        :path => 'auto_complete_for_parent_address',
        :name => 'connect',
        :action => 'auto_complete_for_parent_address',
        :controller => 'parents')
      Rails::Generator::Commands::Create.any_instance.expects(:route).with(
        :path => 'auto_complete_for_testy_first_name',
        :name => 'connect',
        :action => 'auto_complete_for_testy_first_name',
        :controller => 'parents')
      Rails::Generator::Commands::Create.any_instance.expects(:route).with(
        :path => 'auto_complete_for_testy_last_name',
        :name => 'connect',
        :action => 'auto_complete_for_testy_last_name',
        :controller => 'parents')
      Rails::Generator::Commands::Create.any_instance.expects(:route).with(
        :path => 'auto_complete_for_testy_address',
        :name => 'connect',
        :action => 'auto_complete_for_testy_address',
        :controller => 'parents')

      @generator_script.run(generator_script_cmd_line('scaffold_for_view', ['--view', 'has_many_auto_complete:testies'], 'parent'))
    end
  end

  context "A Rails generator script with a child model without a belongs_to association" do
    setup do
      setup_test_model
      setup_parent_test_model(false, false)
      @generator_script = Rails::Generator::Scripts::Generate.new
    end

    should "return a warning when run with view_for and not run any actions" do
      expect_no_actions
      Rails::Generator::Base.logger.expects('warning').with('Model Testy does not contain a belongs_to association for Parent.')
      @generator_script.run(generator_script_cmd_line('view_for', ['--view', 'has_many_auto_complete:testies'], 'parent'))
    end

    should "return a warning when run with scaffold_for_view and not run any actions" do
      expect_no_actions
      Rails::Generator::Base.logger.expects('warning').with('Model Testy does not contain a belongs_to association for Parent.')
      @generator_script.run(generator_script_cmd_line('scaffold_for_view', ['--view', 'has_many_auto_complete:testies'], 'parent'))
    end
  end

  context "A Rails generator script with a child model missing a foreign key" do
    setup do
      setup_test_model
      setup_parent_test_model(false)
      @generator_script = Rails::Generator::Scripts::Generate.new
    end

    should "return a warning when run with view_for and not run any actions" do
      expect_no_actions
      Rails::Generator::Base.logger.expects('warning').with('Model Testy does not contain a foreign key for Parent.')
      @generator_script.run(generator_script_cmd_line('view_for', ['--view', 'has_many_auto_complete:testies'], 'parent'))
    end

    should "return a warning when run with scaffold_for_view and not run any actions" do
      expect_no_actions
      Rails::Generator::Base.logger.expects('warning').with('Model Testy does not contain a foreign key for Parent.')
      @generator_script.run(generator_script_cmd_line('scaffold_for_view', ['--view', 'has_many_auto_complete:testies'], 'parent'))
    end
  end

  context "A Rails generator script with a child model that has a habtm association" do
    setup do
      setup_test_model
      setup_parent_test_model(false, false)
      Testy.class_eval do
        has_and_belongs_to_many :parents
      end
      @generator_script = Rails::Generator::Scripts::Generate.new
    end

    should "not return a warning when run with view_for" do
      stub_actions
      expect_no_warnings
      @generator_script.run(generator_script_cmd_line('view_for', ['--view', 'has_many_auto_complete:testies'], 'parent'))
    end

    should "not return a warning when run with scaffold_for_view" do
      stub_actions
      expect_no_warnings
      @generator_script.run(generator_script_cmd_line('scaffold_for_view', ['--view', 'has_many_auto_complete:testies'], 'parent'))
    end
  end

  context "A Rails generator script with a child model that has_many (through) association" do
    setup do
      setup_test_model
      setup_parent_test_model(false, false)
      Testy.class_eval do
        has_many :parents
      end
      @generator_script = Rails::Generator::Scripts::Generate.new
    end

    should "not return a warning when run with view_for" do
      stub_actions
      expect_no_warnings
      @generator_script.run(generator_script_cmd_line('view_for', ['--view', 'has_many_auto_complete:testies'], 'parent'))
    end

    should "not return a warning when run with scaffold_for_view" do
      stub_actions
      expect_no_warnings
      @generator_script.run(generator_script_cmd_line('scaffold_for_view', ['--view', 'has_many_auto_complete:testies'], 'parent'))
    end
  end

end
