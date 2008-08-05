require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/column/association'

include Streamlined::Column

describe "Streamlined::Column::Association" do
  
  def setup
    @ar_assoc = flexmock(:name => 'some_name', :class_name => 'SomeClass')
    @model = flexmock(:name => 'model')
    @association = Association.new(@ar_assoc, @model, :inset_table, :count)
    @association.stubs(:primary_key_name).returns("some_name_id")
  end
  
  # begin stub classes
  class ::SomeClass
    def self.find(args)
      [:item1, :item2, :item3]
    end
  end

  class ::AnotherClass
    def self.find(args)
      [:item4, :item5]
    end
  end
  # end stub classes
  
  # This will probably change as more stuff moves from ui into assocation
  it "initializer" do
    assert_raise(ArgumentError) { Association.new(@ar_assoc, 'foo', 'bar') }
    assert_equal 'Some Name', @association.human_name
    assert_instance_of(Streamlined::View::ShowViews::Count, @association.show_view)
    assert_instance_of(Streamlined::View::EditViews::InsetTable, @association.edit_view)
  end
  
  it "table name" do
    assert_equal 'some_names', @association.table_name
  end
  
  it "belongs to delegates to underlying association" do
    flexmock(@association, :underlying_association => flexmock(:belongs_to? => :some_result))
    assert_equal :some_result, @association.belongs_to?
  end
  
  it "association" do
    assert @association.association?
  end
  
  it "filterable" do
    assert !@association.filterable?
    @association.filter_column = 'foobar'
    assert @association.filterable?
  end
  
  it "show and edit view symbol args" do
    assert_kind_of Streamlined::View::ShowViews::Count, @association.show_view
    assert_kind_of Streamlined::View::EditViews::InsetTable, @association.edit_view
  end
  
  it "show and edit view array args" do
    a = Association.new(@ar_assoc, nil, [:inset_table], [:count])
    assert_kind_of Streamlined::View::ShowViews::Count, a.show_view
    assert_kind_of Streamlined::View::EditViews::InsetTable, a.edit_view
  end
  
  it "show and edit view instance args" do
    inset_table_class = Streamlined::View::EditViews::InsetTable
    count_class = Streamlined::View::ShowViews::Count
    
    a = Association.new(@ar_assoc, nil, inset_table_class.new, count_class.new)
    assert_kind_of count_class, a.show_view
    assert_kind_of inset_table_class, a.edit_view
  end

  it "show and edit view bad args" do
    assert_raise(ArgumentError) { a = Association.new(@ar_assoc, nil, [:inset_table], Object.new) }
    assert_raise(ArgumentError) { a = Association.new(@ar_assoc, nil, Object.new, [:count]) }
  end
  
  it "items for select with one associable" do
    flexmock(@association).should_receive(:associables).and_return([SomeClass]).once
    assert_equal [:item1, :item2, :item3], @association.items_for_select
  end
  
  it "items for select with many associables" do
    flexmock(@association).should_receive(:associables).and_return([SomeClass, AnotherClass]).twice
    expected = { 'SomeClass' => [:item1, :item2, :item3], 'AnotherClass' => [:item4, :item5] }
    assert_equal expected, @association.items_for_select
  end
  
  it "render td" do
    view = flexmock(:render => 'render', :controller_path => 'controller_path')
    item = flexmock(:id => 123)
    
    expected_js = "Streamlined.Relationships.open_relationship('InsetTable::some_name::123::SomeClass', this, '/controller_path')"
    view.should_receive(:link_to_function).with("Edit", expected_js).and_return('link').once
    view.should_receive(:crud_context).and_return(:list)
    
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>link"
    assert_equal expected, @association.render_td(view, item)
  end
  
  it "render td with read only true" do
    view = flexmock(:render => 'render', :controller_path => 'controller_path')
    item = flexmock(:id => 123)
    @association.read_only = true
    assert_equal "render", @association.render_td(view, item)
  end

  # Here is another way you could do the above test...
  # def test_render_td_with_readonly_true_another_way
  #   view = flexmock(:crud_context=>'edit')
  #   flexmock(@association) do |mock|
  #     mock.should_receive(:render_td_edit).and_return('edit').once
  #     mock.should_receive(:render_td_show).and_return('show').once
  #   end
  #   assert_equal 'edit', @association.render_td(view,nil)
  #   @association.read_only = true
  #   assert_equal 'show', @association.render_td(view,nil)
  # end
  
  it "render td list" do
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>link"
    assert_equal expected, @association.render_td_list(*view_and_item_mocks)
  end
  
  it "render td list with create only true" do
    @association.create_only = true
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>"
    assert_equal expected, @association.render_td_list(*view_and_item_mocks)
  end
  
  it "render td list with read only true" do
    @association.read_only = true
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>"
    assert_equal expected, @association.render_td_list(*view_and_item_mocks)
  end
  
  it "render td list with edit in list false" do
    @association.edit_in_list = false
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>"
    assert_equal expected, @association.render_td_list(*view_and_item_mocks)
  end
  
  it "render td edit with options for select" do
    flexmock(SomeClass).should_receive(:custom_options).and_return([:foo]).once
    @association.options_for_select = :custom_options
    assert_equal "select", @association.render_td_edit(*view_and_item_mocks_for_render_td_edit)
  end
  
  it "render td edit with options for select that accepts item arg" do
    view, item = view_and_item_mocks_for_render_td_edit
    streamlined_item = view.instance_variable_get("@streamlined_item")
    flexmock(SomeClass).should_receive(:custom_options).with(streamlined_item).and_return([:foo]).once
    @association.options_for_select = :custom_options
    assert_equal "select", @association.render_td_edit(view, item)
  end
  
  it "render td edit with help" do
    flexmock(SomeClass).stubs(:custom_options).returns([:foo])
    @association.options_for_select = :custom_options
    @association.help = "This is an optional field"
    expected = "select<div class=\"streamlined_help\">This is an optional field</div>"
    @association.render_td_edit(*view_and_item_mocks_for_render_td_edit).should == expected
  end
  
  private
  def view_and_item_mocks(view_attrs={})
    view = flexmock(:render => 'render', :controller_path => 'controller_path', :link_to_function => 'link')
    item = flexmock(:id => 123)
    [view, item]
  end

  def view_and_item_mocks_for_render_td_edit(options={:unassigned_value => 'Unassigned'})
    item = flexmock("item", :respond_to? => true, :some_name => nil)
    (view = flexmock("view")).should_receive(:select).with('model', 'some_name_id', [[options[:unassigned_value], nil], :foo], { :selected => nil }, {}).and_return("select").once
    flexmock("association", @association) do |mock|
      mock.should_receive(:column_can_be_unassigned?).with(@model, "some_name").and_return(true).once
      mock.should_receive(:has_many? => false).once
      mock.should_receive(:belongs_to? => true).once
      mock.should_receive(:has_and_belongs_to_many? => false).once    
      mock.should_receive(:should_render_quick_add? => false).once
    end
    [view, item]
  end
end