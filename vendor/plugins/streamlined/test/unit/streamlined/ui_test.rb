require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))
require 'streamlined/ui'

describe "RelevanceModuleHelpers" do
  def setup
    @inst = Relevance::ModuleHelper 
  end
  it "reader from options" do
    assert_equal("@foo", @inst.reader_from_options("foo"))
    assert_equal("defined?(@foo) ? @foo : []", @inst.reader_from_options("foo", :default=>[]))
  end
end

describe "Streamlined::UI" do
  class TestModel; end
  def setup
    @ui = Streamlined::UI.new(TestModel)
  end

  it "knows its sortable columns" do
    flexmock(@ui).should_receive(:list_columns).and_return([flexstub(:name => "foo")])
    @ui.has_sortable_column?(:foo).should == true
    @ui.has_sortable_column?(:bar).should == false
  end
    
  it "style class for with empty style classes hash" do
    assert_equal({}, @ui.style_classes)
    assert_nil @ui.style_class_for(:list, :cell, nil)
  end
  
  it "style class for with string" do
    flexmock(@ui).should_receive(:style_classes).and_return(:list => { :cell => "color: red" })
    assert_equal "color: red", @ui.style_class_for(:list, :cell, nil)
    assert_nil @ui.style_class_for(:list, :row, nil)
  end
  
  it "style class for with proc" do
    flexmock(@ui).should_receive(:style_classes).and_return(:list => { :cell => Proc.new { |i| i.style }})
    item = flexmock(:style => "color: black")
    assert_equal "color: black", @ui.style_class_for(:list, :cell, item)
  end
  
  it "read only" do
    assert_equal nil, @ui.read_only
    assert_equal true, @ui.read_only(true)
    assert_equal true, @ui.read_only
  end
  
  it "pagination" do
    assert_equal true, @ui.pagination
    assert_equal "foo", @ui.pagination("foo")
    assert_equal "foo", @ui.pagination
    assert_equal "bar", @ui.pagination="bar"
    assert_equal "bar", @ui.pagination
    assert_false @ui.pagination=false
    assert_false @ui.pagination
  end
  
  it "model" do
    flexstub(@ui).should_receive(:default_model).and_return(Class)
    assert_equal TestModel, @ui.model
    # TODO: where are these model methods used?
    # assert_equal String, @ui.model(:string)
    # assert_equal String, @ui.model
    # assert_equal Fixnum, @ui.model("Fixnum")
    # assert_equal Fixnum, @ui.model
  end
  
  it "quick button defaults" do
    assert_equal true, @ui.quick_delete_button
    assert_equal true, @ui.quick_edit_button
    assert_equal true, @ui.quick_new_button
    assert_equal true, @ui.quick_show_button
  end
  
  it "new submit button" do
    assert_equal true, @ui.new_submit_button[:ajax]
    assert_equal false, @ui.new_submit_button({:ajax => false})[:ajax]
    assert_equal false, @ui.new_submit_button[:ajax]
  end
  
  it "edit submit button" do
    assert_equal true, @ui.edit_submit_button[:ajax]
    assert_equal false, @ui.edit_submit_button({:ajax => false})[:ajax]
    assert_equal false, @ui.edit_submit_button[:ajax]
  end
  
  it "header and footer partials have defaults" do
    assert_equal({}, @ui.header_partials)
    assert_equal({}, @ui.after_header_partials)
    assert_equal({}, @ui.footer_partials)
  end
  
  it "custom columns group" do
    first_name = flexmock(:name => :first_name)
    last_name = flexmock(:name => :last_name)
    flexmock(TestModel).should_receive(:columns).and_return([first_name, last_name]).once
    @ui.custom_columns_group(:group, :first_name, :last_name)
    assert_equal 2, @ui.custom_columns_group(:group).size
  end

  it "quick add columns with args" do
    flexmock(@ui).should_receive(:convert_args_to_columns).and_return(:return_val).once
    assert_equal :return_val, @ui.quick_add_columns(:anything)
  end

  it "quick add columns with no args" do
    addition = flexmock("addition")
    addition.should_receive(:is_a?).and_return(true).once
    flexmock(@ui).should_receive(:user_columns).and_return([:anything, addition]).once
    assert_equal [:anything], @ui.quick_add_columns
  end
  
  it "columns with additional column pairs with no columns" do
    flexmock(@ui).should_receive(:list_columns).and_return([])
    assert_equal [], @ui.columns_with_additional_column_pairs
  end
  
  it "columns with additional column pairs" do
    contact_column = flexmock("list_column")
    contact_column.should_receive(:additional_column_pairs).and_return([:first_name])    
    flexmock(@ui).should_receive(:list_columns).and_return([contact_column])
    assert_equal [contact_column], @ui.columns_with_additional_column_pairs
  end
  
  it "additional includes with no columns" do
    flexmock(@ui).should_receive(:list_columns).and_return([])
    assert_equal [], @ui.additional_includes
  end
  
  it "additional includes" do
    column = flexmock("list_column")
    column.should_receive(:additional_includes).and_return([:addresses])    
    column2 = flexmock("list_column2")
    column2.should_receive(:additional_includes).and_return([:dogs, :cats])    
    column3 = flexmock("list_column3")
    column3.should_receive(:additional_includes).and_return([:doctor => [:contact]])    
    flexmock(@ui).should_receive(:list_columns).and_return([column, column2, column3])
    assert_equal [:addresses, :dogs, :cats, {:doctor => [:contact]}], @ui.additional_includes
  end
  
  it "export defaults" do
    assert_equal true, @ui.allow_full_download
    assert_equal true, @ui.default_full_download
    assert_equal ',',  @ui.default_separator
    assert_equal nil,  @ui.default_skip_header
    assert_equal :enhanced_xml_file, @ui.default_exporter
    assert_equal [],   @ui.default_deselected_columns
  end
  
  it "default deselected column with symbol" do
    @ui.default_deselected_columns :a_column
    assert_true  @ui.default_deselected_column?(:a_column)
    assert_false @ui.default_deselected_column?(:not_there)
  end

  it "default deselected column with array" do
    columns = :a_column, :b_column, :c_column
    @ui.default_deselected_columns columns
    columns.each {|column| assert_true @ui.default_deselected_column?(column) }
    assert_false @ui.default_deselected_column?(:not_there)
  end

  it "displays exporter with symbol" do
    @ui.exporters :none
    assert_true  @ui.displays_exporter?(:none)
    assert_false @ui.displays_exporter?(:not_there)
  end

  it "displays exporter with array" do
    formats = :csv, :xml, :yaml
    @ui.exporters formats
    formats.each {|format| assert_true @ui.displays_exporter?(format) }
    assert_false @ui.displays_exporter?(:not_there)
  end

  it "default exporter with defaults" do
    assert_true @ui.default_exporter?(@ui.default_exporter)
  end

  it "default exporter with one" do
    exporter = :csv
    @ui.exporters exporter
    assert_true @ui.default_exporter?(exporter)
  end

  it "default exporter with several including default" do
    exporters = :yaml, @ui.default_exporter, :json
    @ui.exporters exporters
    assert_true @ui.default_exporter?(@ui.default_exporter)
  end

  it "default exporter with several excluding default" do
    exporters = :xml, :yaml, :json
    @ui.exporters exporters
    assert_true @ui.default_exporter?(:xml)
  end

  it "export labels" do
    export_labels =    {:enhanced_xml_file  => '&nbsp;Enhanced&nbsp;XML&nbsp;To&nbsp;File',
                        :xml_stylesheet     => '&nbsp;XML&nbsp;Stylesheet',
                        :enhanced_xml       => '&nbsp;Enhanced&nbsp;XML',
                        :xml                => '&nbsp;xml',
                        :csv                => '&nbsp;csv',
                        :json               => '&nbsp;json',
                        :yaml               => '&nbsp;yaml'
                       }
    assert_equal export_labels, @ui.export_labels                       
  end
  
  describe "sql_pair" do
    def setup
      @ui = Streamlined::UI.new(TestModel)
    end
    
    it "should return default pair" do
      ActiveRecord::Base.stubs(:connection).returns(stub(:quote => %Q{"joe"}))
      @ui.sql_pair("user", "joe").should == "user LIKE \"joe\""
    end
    
    it "should return case-sensitive pair" do
      ActiveRecord::Base.stubs(:connection).returns(stub(:quote => %Q{"joe"}))
      @ui.stubs(:table_filter).returns(:case_sensitive => false)
      @ui.sql_pair("user", "joe").should == "UPPER(user) LIKE UPPER(\"joe\")"
    end
    
    it "should return non-case-sensitive pair" do
      ActiveRecord::Base.stubs(:connection).returns(stub(:quote => %Q{"joe"}))
      @ui.stubs(:table_filter).returns(:case_sensitive => true)
      @ui.sql_pair("user", "joe").should == "user LIKE \"joe\""
    end
  end
  
  describe "show_table_filter?" do
    def setup
      @ui = Streamlined::UI.new(TestModel)
    end
    
    it "should return true when table_filter hash :show key is set to true" do
      @ui.stubs(:table_filter).returns(:show => true)
      assert @ui.show_table_filter?
    end

    it "should return false when table_filter hash :show key is set to false" do
      @ui.stubs(:table_filter).returns(:show => false)
      assert !@ui.show_table_filter?
    end
    
    it "should return false when table_filter hash has no :show key" do
      @ui.stubs(:table_filter).returns({})
      assert !@ui.show_table_filter?
    end

    it "should return true when table_filter returns true" do
      @ui.stubs(:table_filter).returns(true)
      assert @ui.show_table_filter?
    end

    it "should return false when table_filter returns false" do
      @ui.stubs(:table_filter).returns(false)
      assert !@ui.show_table_filter?
    end
    
    describe "case_sensitive_filtering?" do
      def setup
        @ui = Streamlined::UI.new(TestModel)
      end

      it "should return true when table_filter hash :case_sensitive key is set to true" do
        @ui.stubs(:table_filter).returns(:case_sensitive => true)
        assert @ui.case_sensitive_filtering?
      end

      it "should return false when table_filter hash :case_sensitive key is set to false" do
        @ui.stubs(:table_filter).returns(:case_sensitive => false)
        assert !@ui.case_sensitive_filtering?
      end
      
      it "should return false when table_filter hash has no :case_sensitive key" do
        @ui.stubs(:table_filter).returns({})
        assert !@ui.case_sensitive_filtering?
      end

      it "should return false when table_filter returns true" do
        @ui.stubs(:table_filter).returns(true)
        assert !@ui.case_sensitive_filtering?
      end

      it "should return false when table_filter returns false" do
        @ui.stubs(:table_filter).returns(false)
        assert !@ui.case_sensitive_filtering?
      end
    end
  end
end
