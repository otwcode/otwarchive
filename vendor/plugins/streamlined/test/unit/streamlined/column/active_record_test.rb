require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/column/addition'


describe "Streamlined::Column::ActiveRecord" do
  include Streamlined::Column
  
  def setup
    ar_column = flexmock(:name => 'column')
    model = flexmock(:name => 'model')
    @class_under_test = Streamlined::Column::ActiveRecord
    @ar = @class_under_test.new(ar_column, model)
  end
  
  it "initialize" do
    ar = @class_under_test.new(:foo, nil)
    assert_equal :foo, ar.ar_column
    assert_nil ar.human_name
  end
  
  it "initialize with human name" do
    ar = @class_under_test.new(flexmock(:human_name => 'Foo'), nil)
    assert_equal 'Foo', ar.human_name
  end
  
  it "active record?" do
    assert @class_under_test.new(nil, nil).active_record?
  end
  
  it "table name" do
    ar = @class_under_test.new(nil, flexmock(:table_name => 'Foo'))
    assert_equal 'Foo', ar.table_name
  end
  
  it "filterable defaults to true" do
    assert @class_under_test.new(:foo, nil).filterable
  end
  
  it "names delegate to ar column" do
    ar = @class_under_test.new(ar_column('foo_bar', 'Foo bar'), nil)
    assert_equal 'foo_bar', ar.name
    assert_equal 'Foo Bar', ar.human_name
  end
  
  it "human name can be set manually" do
    ar = @class_under_test.new(ar_column('foo_bar', 'Foo bar'), nil)
    ar.human_name = 'Bar Foo'
    assert_equal 'Bar Foo', ar.human_name
  end
  
  it "enumeration can be set" do
    assert_nil @ar.enumeration
    @ar.enumeration = %w{ A B C }
    assert_equal [%w(A A), %w(B B), %w(C C)], @ar.enumeration
  end
  
  it "equal" do
    a1 = @class_under_test.new(:foo, nil)
    a2 = @class_under_test.new(:foo, nil)
    a3 = @class_under_test.new(:bar, nil)
    a4 = @class_under_test.new(nil, nil)
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  it "equal with human name" do
    (a1 = @class_under_test.new(:foo, nil)).human_name = 'Foo'
    (a2 = @class_under_test.new(:foo, nil)).human_name = 'Foo'
    (a3 = @class_under_test.new(:foo, nil)).human_name = 'Bar'
    (a4 = @class_under_test.new(:foo, nil)).human_name = nil
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  it "equal with enumeration" do
    (a1 = @class_under_test.new(:foo, nil)).enumeration = ['Foo']
    (a2 = @class_under_test.new(:foo, nil)).enumeration = ['Foo']
    (a3 = @class_under_test.new(:foo, nil)).enumeration = ['Bar']
    (a4 = @class_under_test.new(:foo, nil)).human_name = nil
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  it "edit view" do
    assert @ar.edit_view.is_a?(Streamlined::View::EditViews::EnumerableSelect)
  end
  
  it "render td edit" do
    (view = mock).expects(:input).with('model', 'column', {}).returns('input').once
    @ar.render_td_edit(view, 'item')
  end
  
  it "render td edit with enumeration" do
    @ar.enumeration = %w{ A B C }
    flexmock(@ar).should_receive(:render_enumeration_select).with('view', 'item').and_return('select').once
    assert_equal 'select', @ar.render_td_edit('view', 'item')
  end
  
  it "render td edit with checkbox" do
    @ar.check_box = true
    (view = mock).expects(:check_box).with('model', 'column', {}).returns('input').once
    @ar.render_td_edit(view, 'item')
  end
  
  it "render td edit with help" do
    view = stub(:input => "content")
    @ar.help = "This is an optional field"
    expected = "content<div class=\"streamlined_help\">This is an optional field</div>"
    @ar.render_td_edit(view, 'item').should == expected
  end
  
  it "render td edit with html options" do
    @ar.html_options = { :class => 'foo_class' }
    (view = flexmock).should_receive(:input).with('model', 'column', { :class => 'foo_class' }).and_return('result').once
    assert_equal 'result', @ar.render_td_edit(view, 'item')
  end
  
  it "render td as edit" do
    view = flexmock(:model_underscore => 'model', :crud_context => :edit)
    view.should_receive(:input).with('model', 'column', {}).and_return('input').once
    assert_equal 'input', @ar.render_td(view, nil)
  end
  
  it "render td as list" do
    view = flexmock(:crud_context => :list)
    item = flexmock(:column => 'value', :id => 123)
    assert_equal 'value', @ar.render_td(view, item)
  end
  
  it "render td show with enumeration and blank value" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    item = flexmock(:column => nil)
    assert_equal "Unassigned", @ar.render_td_show(@view, item)
  end
  
  it "render td with array-backed enumeration" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @view.should_receive(:crud_context).and_return(:list).once
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>link"
    assert_equal expected, @ar.render_td(@view, @item)
  end
  
  it "render td with hash-backed enumeration" do
    setup_mocks(:column => 1)
    @ar.enumeration = { "A" => 1, "B" => 2, "C" => 3 }
    @view.should_receive(:crud_context).and_return(:list).once
    expected = "<div id=\"EnumerableSelect::column::123::\">A</div>link"
    assert_equal expected, @ar.render_td(@view, @item)
  end
  
  it "render td with hash-backed enumeration and nil column value" do
    setup_mocks(:column => nil)
    @ar.enumeration = { "A" => 1, "B" => 2, "C" => 3 }
    @view.should_receive(:crud_context).and_return(:list).once
    expected = "<div id=\"EnumerableSelect::column::123::\">Unassigned</div>link"
    assert_equal expected, @ar.render_td(@view, @item)
  end
  
  it "render td with 2d array-backed enumeration" do
    setup_mocks(:column => 1)
    @ar.enumeration = [["A", 1], ["B", 2], ["C", 3]]
    @view.should_receive(:crud_context).and_return(:list).once
    expected = "<div id=\"EnumerableSelect::column::123::\">A</div>link"
    assert_equal expected, @ar.render_td(@view, @item)
  end
  
  it "render td with 2d array-backed enumeration and nil column value" do
    setup_mocks(:column => nil)
    @ar.enumeration = [["A", 1], ["B", 2], ["C", 3]]
    @view.should_receive(:crud_context).and_return(:list).once
    expected = "<div id=\"EnumerableSelect::column::123::\">Unassigned</div>link"
    assert_equal expected, @ar.render_td(@view, @item)
  end
  
  it "render td list with enumeration and link" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.link_to = { :action => "show" }
    @ar.edit_in_list = false
    flexmock(@view).should_receive(:wrap_with_link).and_return("render_with_link").once
    assert_equal "<div id=\"EnumerableSelect::column::123::\">render_with_link</div>", @ar.render_td_list(@view, @item)
  end
  
  it "render td list with enumeration and create only true" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.edit_in_list = false
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>"
    assert_equal expected, @ar.render_td_list(@view, @item)
  end
  
  it "render td list with enumeration and read only true" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.read_only = true
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>"
    assert_equal expected, @ar.render_td_list(@view, @item)
  end
  
  it "render td list with enumeration and edit in list false" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.read_only = true
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>"
    assert_equal expected, @ar.render_td_list(@view, @item)
  end
  
  it "render enumeration select" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    choices = [['Unassigned', nil], ['A', 'A'], ['B', 'B'], ['C', 'C']]
    @view.should_receive(:select).with('model', 'column', choices).once
    @ar.render_enumeration_select(@view, @item)
  end
  
  it "render enumeration select with hash" do
    setup_mocks
    @ar.enumeration = { 'A' => 1, 'B' => 2, 'C' => 3 }
    choices = [['Unassigned', nil], ['A', 1], ['B', 2], ['C', 3]]
    @view.should_receive(:select).with('model', 'column', choices).once
    @ar.render_enumeration_select(@view, @item)
  end
  
  it "render enumeration select with 2d array" do
    setup_mocks
    @ar.enumeration = [['A', 1], ['B', 2], ['C', 3]]
    choices = [['Unassigned', nil], ['A', 1], ['B', 2], ['C', 3]]
    @view.should_receive(:select).with('model', 'column', choices).once
    @ar.render_enumeration_select(@view, @item)
  end
  
  it "render enumeration select with custom unassigned value" do
    setup_mocks
    @ar.enumeration = []
    @ar.unassigned_value = 'none'
    choices = [['none', nil]]
    @view.should_receive(:select).with('model', 'column', choices).once
    @ar.render_enumeration_select(@view, @item)
  end
  
  it "render enumeration select with html options" do
    setup_mocks
    @ar.enumeration = []
    @ar.html_options = { :class => 'foo_class' }
    @view.should_receive(:select).with('model', 'column', [["Unassigned", nil]], {}, { :class => 'foo_class' }).once
    @ar.render_enumeration_select(@view, @item)
  end
  
  describe "enumeration" do
    def setup
      # TODO: having to duplicate this setup method here smells bad
      ar_column = flexmock(:name => 'column')
      model = flexmock(:name => 'model')
      @class_under_test = Streamlined::Column::ActiveRecord
      @ar = @class_under_test.new(ar_column, model)
    end
    
    it "converts hash to sorted 2d array" do
      @ar.enumeration = { :foo => "bar", :bat => "boo" }
      @ar.enumeration.should == [[:bat, "boo"], [:foo, "bar"]]
    end
    
    it "converts 1d array to 2d array" do
      @ar.enumeration = [1, 2, 3]
      @ar.enumeration.should == [[1, 1], [2, 2], [3, 3]]
    end
    
    it "returns 2d array as is" do
      @ar.enumeration = [%w(A A), %w(B B), %w(C C)]
      @ar.enumeration.should == [%w(A A), %w(B B), %w(C C)]
    end
    
    it "returns nil if enumeration is nil" do
      @ar.enumeration = nil
      @ar.enumeration.should.be nil
    end
  end
  
private
  def ar_column(name, human_name)
    flexmock(:name => name, :human_name => human_name)
  end
  
  def setup_mocks(item_attrs={})
    @view = flexmock(:controller_path => 'controller_path', :link_to_function => 'link')
    @item = flexmock(item_attrs.reverse_merge(:id => 123, :column => 'render'))
  end
end
