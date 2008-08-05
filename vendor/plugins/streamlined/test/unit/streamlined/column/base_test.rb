require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/column/association'
require 'streamlined/column/active_record'
require 'streamlined/column/addition'

include Streamlined::Column
include Streamlined::Context
describe "Streamlined::Column::Base" do
  
  def setup
    @ar_assoc = flexmock(:name => "some_name", :class_name => "SomeName")
    parent_model = flexmock(:name => "ParentModel")
    @addition = Addition.new(:test_addition, parent_model)
  end                                    
  
  def teardown
    Streamlined::PermanentRegistry.reset
  end
  
  it "human name" do
    assert_equal "Test Addition", @addition.human_name
  end
  
  it "human name explicitly set" do
    @addition.human_name = "foo bar"
    @addition.human_name_explicitly_set = true
    assert_equal "foo bar", @addition.human_name
  end
  
  it "has many" do
    assert_false Streamlined::Column::Base.new.has_many?
  end
  
  it "belongs to" do
    assert !@addition.belongs_to?
  end
  
  it "association?" do
    assert !@addition.association?
  end
  
  it "active record?" do
    assert !@addition.active_record?
  end
  
  it "unassigned value receives default" do
    assert_equal "Unassigned", @addition.unassigned_value
  end
  
  it "render content" do
    (item = flexmock).should_receive(:send).with("test_addition").and_return("<b>content</b>").once
    assert_equal "&lt;b&gt;content&lt;/b&gt;", @addition.render_content(nil, item)
  end
  
  it "render content with custom display format for" do
    (item = flexmock).should_receive(:send).with("test_addition").and_return("Voldemort").once
    assert_equal "Voldemort", @addition.render_content(nil, item)
    Streamlined.display_format_for("Voldemort") { "He Who Must Not Be Named" }
    assert_equal "He Who Must Not Be Named", @addition.render_content(nil, item)
  end

  it "renderers" do
    assert_equal_sets Set.new(["render_th",
                               "render_td_new",
                               "render_td_edit",
                               "render_tr_edit",
                               "render_td_show",
                               "render_td",
                               "render_id",
                               "render_td_list",
                               "render_content",
                               "render_tr_show"]),
                      @addition.renderers,
                      "The set of render_ methods has changed. Make sure the semantics of renderer= are correct, then fix this test to pass again."
  end
  
  it "render td with wrapper" do
    view = stub(:crud_context => :edit)
    item = stub(:send => "content")
    @addition.wrapper = Proc.new { |c| "<<<#{c}>>>" }
    assert_equal '<<<content>>>', @addition.render_td(view, item)
  end
  
  it "renderer block that does not yield" do
    @addition.render_wrapper = Proc.new {|old_meth, *args| "#{old_meth.name} rendered!"}
    @addition.renderers.each do |renderer|
      assert_equal "#{renderer} rendered!", @addition.send(renderer)
    end
  end
  
  it "renderer block that yields" do
    @addition.allow_html = true
    (item = flexmock).should_receive(:send).with("test_addition").and_return("header me").times(2)
    assert_equal "header me", @addition.render_content(nil, item)
    @addition.render_wrapper = Proc.new {|meth, *args| "<h1>#{meth.call(*args)}</h1>"}
    assert_equal "<h1>header me</h1>", @addition.render_content(nil, item)
  end
  
  it "renderer view method" do
    @addition.render_wrapper = :do_that_render
    (view = flexmock).should_receive(:do_that_render).with(Method, FlexMock, nil).and_return("did render").once
    assert_equal "did render", @addition.render_content(view, nil)
  end
  
  it "render content with allow html set to true" do
    @addition.allow_html = true
    (item = flexmock).should_receive(:send).with("test_addition").and_return("<b>content</b>").once
    assert_equal "<b>content</b>", @addition.render_content(nil, item)
  end
  
  it "is displayable in context" do
    view = flexmock(:crud_context => :edit)
    assert !@addition.is_displayable_in_context?(view, :item)
    
    association = Association.new(@ar_assoc, nil, :inset_table, :list)
    assert association.is_displayable_in_context?(view, :item)
    
    ar_column = flexmock(:name => "column")
    ar = Streamlined::Column::ActiveRecord.new(ar_column, nil)
    assert ar.is_displayable_in_context?(view, :item)
    
    item = flexmock(:should_display_column_in_context? => true)
    assert ar.is_displayable_in_context?(view, item)
    item = flexmock(:should_display_column_in_context? => false)
    assert !ar.is_displayable_in_context?(view, item)
  end
  
  it "is displayable in context with create only set to true" do
    @addition.create_only = true
    assert_displayable_in_contexts @addition, :new => false, :show => true, :list => true, :edit => false
    
    association = Association.new(@ar_assoc, nil, :inset_table, :list)
    association.create_only = true
    assert_displayable_in_contexts association, :new => true, :show => true, :list => true, :edit => false
    
    ar_column = flexmock(:name => "column")
    ar = Streamlined::Column::ActiveRecord.new(ar_column, nil)
    ar.create_only = true
    assert_displayable_in_contexts ar, :new => true, :show => true, :list => true, :edit => false
  end
  
  it "is displayable in context with update only set to true" do
    @addition.update_only = true
    assert_displayable_in_contexts @addition, :new => false, :show => true, :list => true, :edit => false
    
    association = Association.new(@ar_assoc, nil, :inset_table, :list)
    association.update_only = true
    assert_displayable_in_contexts association, :new => false, :show => true, :list => true, :edit => true
    
    ar_column = flexmock(:name => "column")
    ar = Streamlined::Column::ActiveRecord.new(ar_column, nil)
    ar.update_only = true
    assert_displayable_in_contexts ar, :new => false, :show => true, :list => true, :edit => true
  end
  
  it "is displayable in context with hide if unassigned set to true" do
    @addition.hide_if_unassigned = true
    view = flexmock(:crud_context => :show)
    
    item = flexmock(:test_addition => nil)
    assert !@addition.is_displayable_in_context?(view, item)
    
    item = flexmock(:test_addition => "value")
    assert @addition.is_displayable_in_context?(view, item)
  end
  
  it "render th" do
    association = Association.new(@ar_assoc, nil, :inset_table, :count)
    flexmock(association).should_receive(:sort_image => "<img src=\"up.gif\">")
    assert_equal expected_th, association.render_th(nil, nil)
  end
  
  it "render id for list view" do
    view, item = flexmock(:crud_context => :list), flexmock(:id => 123)
    assert_equal "parent_model_123_test_addition", @addition.render_id(view, item)
  end
  
  it "render id for show view" do
    view, item = flexmock(:crud_context => :show), flexmock(:id => 123)
    assert_equal "sl_field_parent_model_test_addition", @addition.render_id(view, item)
  end
  
  it "wrapper" do
    association = Association.new(@ar_assoc, nil, :inset_table, :count)
    assert_equal "content", association.wrap("content")
    association.wrapper = :object_that_does_not_respond_to_call
    assert_equal "content", association.wrap("content")
    association.wrapper = Proc.new { |c| "<<<#{c}>>>" }
    assert_equal "<<<content>>>", association.wrap("content")
  end
  
private
  def expected_th
    returning Builder::XmlMarkup.new do |xml|
      xml.th(:class => "sortSelector", :scope => "col", :col => "name") do
        xml << "Some name<img src=\"up.gif\">"
      end
    end
  end
  
  def assert_displayable_in_contexts(column, expectations={})
    assert_equal expectations[:new],  column.is_displayable_in_context?(flexmock(:crud_context => :new), :item)
    assert_equal expectations[:show], column.is_displayable_in_context?(flexmock(:crud_context => :show), :item)
    assert_equal expectations[:list], column.is_displayable_in_context?(flexmock(:crud_context => :list), :item)
    assert_equal expectations[:edit], column.is_displayable_in_context?(flexmock(:crud_context => :edit), :item)
  end
end