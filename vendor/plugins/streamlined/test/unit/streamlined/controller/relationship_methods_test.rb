require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/controller/relationship_methods'

class StubClass
  def self.find(value)
    'new_item'
  end
end

describe "Streamlined::Controller::RelationshipMethods" do
  def setup
    @inst = Object.new
    class <<@inst
      include Streamlined::Controller::RelationshipMethods
      attr_accessor :params, :crud_context
      def instance=(value); end
    end
  end
  
  it "show relationship" do
    @inst.params = { :id => '1', :relationship => 'person' }
    flexmock(@inst) do |mock|
      mock.should_receive(:model).and_return(flexmock(:find => :item))
      mock.should_receive(:context_column).with('person').and_return(:relationship).once
      mock.should_receive(:render_show_view_partial).with(:relationship, :item).once
    end
    @inst.show_relationship
  end
  
  it "renders show view partial" do
    show_view = flexmock('show_view', :partial => :partial)
    relationship = flexmock('relationship', :show_view => show_view)
    flexmock(@inst) do |mock|
      mock.should_receive(:render).with(:file => :partial, :use_full_path => false, :locals => {:item => :item, :relationship => relationship, :streamlined_def => show_view}).once
    end
    @inst.render_show_view_partial(relationship, :item)
  end
  
  it "edit relationship" do
    @inst.params = { :id => '1', :relationship => 'person' }
    rel_type = flexmock(:edit_view => flexmock(:partial => 'partial'))
    flexmock(@inst) do |mock|
      mock.should_receive(:model).and_return(flexmock('model', :find => nil))
      mock.should_receive(:context_column).and_return(rel_type).once
      mock.should_receive(:set_items_and_all_items).with(rel_type).once
      expected_render_args = { :file => 'partial', :use_full_path => false, :locals => { :relationship => rel_type }}
      mock.should_receive(:render).with(expected_render_args).once
    end
    @inst.edit_relationship
  end
    
  it "update relationship" do
    @inst.params = { :id => '1', :rel_name => 'rel_name', :klass => 'StubClass', :item => { '1' => 'on' }}
    build_update_relationship_mocks
    @inst.update_relationship
  end
  
  it "update relationship without item" do
    @inst.params = { :id => '1', :rel_name => 'rel_name', :klass => 'StubClass' }
    build_update_relationship_mocks
    @inst.update_relationship
  end
  
  it "update n to one with nil item" do
    @inst.params = { :id => '1', :rel_name => 'rel_name' }
    build_n_to_one_mocks
    @inst.update_n_to_one
  end
  
  it "update n to one with item and klass" do
    @inst.params = { :id => '1', :rel_name => 'rel_name', :item => '1', :klass => 'StubClass' }
    build_n_to_one_mocks
    @inst.update_n_to_one
  end
  
  it "update n to one with item and class name" do
    @inst.
    params = { :id => '1', :rel_name => 'rel_name', :item => '1::StubClass' }
    build_n_to_one_mocks
    @inst.update_n_to_one
  end
  
  
  def build_n_to_one_mocks
    rel_type = flexmock('edit_view', :edit_view => flexmock(:partial => 'partial'))
    model_ui = flexmock('relationships', :relationships => { :rel_name => rel_type })
    current_item = flexmock('instance', :save => true, :rel_name= => nil, :rel_name => flexmock('rel_name', :clear => nil, :push => nil, :replace => nil))
    flexmock(@inst) do |mock|
      mock.should_receive(:instance).and_return(current_item)
      mock.should_receive(:model).and_return(flexmock('model', :find => current_item))
      mock.should_receive(:render).with(:nothing => true).once
    end
  end
    
  def build_update_relationship_mocks
    rel_type = flexmock('edit_view', :edit_view => flexmock(:partial => 'partial'))
    model_ui = flexmock('relationships', :relationships => { :rel_name => rel_type })
    current_item = flexmock('instance', :save => true, :rel_name => flexmock('rel_name', :clear => nil, :push => nil, :replace => nil))
    flexmock(@inst) do |mock|
      mock.should_receive(:context_column).and_return(rel_type)
      mock.should_receive(:instance).and_return(current_item)
      mock.should_receive(:model).and_return(flexmock('model', :find => current_item))
      mock.should_receive(:render).with(:nothing => true).once
    end
  end
end