require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_functional_helper'))
require 'streamlined/controller/enumeration_methods'

describe "Streamlined::Controller::EnumerationMethods" do
  include Streamlined::Controller::EnumerationMethods
  attr_accessor :instance
  
  it "edit enumeration" do
    setup_mocks(:enumeration => ['all', 'items'])
    should_render_with_partial('edit_partial')
    assert_equal 'render_results', edit_enumeration
    assert_equal [['all', 'all'], ['items', 'items']], @all_items
    assert_equal 'selected_item', @selected_item
    assert_equal 'selected_item', instance.foo
    assert_equal 'foo', @enumeration_name
  end
  
  it "edit enumeration with hash" do
    setup_mocks(:enumeration => { 'all' => 1, 'items' => 2 })
    should_render_with_partial('edit_partial')
    assert_equal 'render_results', edit_enumeration
    assert_equal [['items', 2], ['all', 1]], @all_items
  end
  
  it "edit enumeration with 2d array" do
    setup_mocks(:enumeration => [['all', 1], ['items', 2]])
    should_render_with_partial('edit_partial')
    assert_equal 'render_results', edit_enumeration
    assert_equal [['all', 1], ['items', 2]], @all_items
  end
  
  it "show enumeration" do
    setup_mocks(:enumeration => ['all', 'items'])
    should_render_with_partial('show_partial')
    assert_equal 'render_results', show_enumeration
    assert_equal 'selected_item', instance.foo
  end
  
  it "update enumeration" do
    setup_mocks(:enumeration => ['all', 'items'])
    @item.should_receive(:update_attribute).with("foo", nil).once
    flexmock(self).should_receive(:render).with(:nothing => true).and_return('render_results').once
    assert_equal 'render_results', update_enumeration
    assert_equal 'selected_item', instance.foo
  end

private
  def setup_mocks(options={})
    @item = flexmock(:foo => 'selected_item')
    show_view = flexmock(:partial => 'show_partial')
    edit_view = flexmock(:partial => 'edit_partial')
    @rel_type = flexmock(:enumeration => options[:enumeration], :edit_view => edit_view, :show_view => show_view)
    
    (model = flexmock).should_receive(:find).with('123').and_return(@item).once
    (model_ui = flexmock).stubs(:scalars).returns(:foo => @rel_type)
    
    flexmock(self, :model => model)
    flexmock(self, :model_ui => model_ui)
    flexmock(self, :params => { :id => '123', :enumeration => 'foo', :rel_name => 'foo' })
  end
  
  def should_render_with_partial(partial)
    render_options = { :file => partial, :use_full_path => false, :locals => { :item => @item, :relationship => @rel_type }}
    flexmock(self).should_receive(:render).with(render_options).and_return('render_results').once
  end
  
end
