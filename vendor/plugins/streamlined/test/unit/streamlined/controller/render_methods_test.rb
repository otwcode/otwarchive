require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/controller/render_methods'

describe "Streamlined::Controller::RenderMethods" do
  include Streamlined::Controller::RenderMethods
  attr_accessor :instance, :filters
  
  # begin stub methods
  def controller_name
    "people"
  end
  
  def controller_path
    "people"
  end
  
  def managed_views_include?(action)
    true
  end

  def managed_partials_include?(action)
    true
  end
  
  def params
    { :action => 'edit' }
  end
  
  def self.filters
    @filters ||= {}
  end
  
  def self.render_filters
    filters[:render] || {}
  end
  # end stub methods
  
  it "render or redirect with render" do
    (@instance = flexmock).should_receive(:id).and_return(123).once
    flexmock(self).should_receive(:respond_to).once  # not sure how to test blocks w/flexmock?
    render_or_redirect(:success, 'show')
    assert_equal 123, @id
  end
  
  it "render or redirect with redirect" do
    (@instance = flexmock).should_receive(:id).and_return(123).once
    (request = flexmock).should_receive(:xhr?).and_return(false).once
    flexmock(self) do |mock|
      mock.should_receive(:request).and_return(request).once
      mock.should_receive(:redirect_to).with(:redirect_to => 'show').once
    end
    render_or_redirect(:success, nil, :redirect_to => 'show')
    assert_equal 123, @id
  end
  
  it "render or redirect with render filter proc" do
    (@instance = flexmock).should_receive(:id).and_return(123).once
    flexmock(self).should_receive(:instance_eval).at_least.once
    self.class.filters[:render] = { :edit => { :success => Proc.new { render :text => 'hello world' }}}
    render_or_redirect(:success, 'show')
    assert_equal 123, @id
  end
  
  it "execute render filter with proc" do
    proc = Proc.new { render :text => 'hello world' }
    flexmock(self).should_receive(:instance_eval).at_least.once
    # TODO: why isn't this working?
    #flexmock(self).should_receive(:render).with(:text => 'hello world').once
    execute_render_filter(proc)
  end
  
  it "execute render filter with symbol" do
    flexmock(self).should_receive(:method_to_invoke).once
    execute_render_filter(:method_to_invoke)
  end
  
  it "execute render filter with invalid args" do
    assert_raises(ArgumentError) { execute_render_filter("bad_args")}
  end
  
  def pretend_template_exists(exists)
    flexstub(self).should_receive(:specific_template_exists?).and_return(exists)
  end
  
  it "convert partial options for generic" do
    pretend_template_exists(false)
    options = {:partial=>"list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:layout=>false, :file=>generic_view("_list"), :other=>"1", :use_full_path => false}, options)
  end

  it "convert partial options and layout for generic" do
    pretend_template_exists(false)
    options = {:partial=>"list", :other=>"1", :layout=>true}
    convert_partial_options(options)
    assert_equal({:layout=>true, :file=>generic_view("_list"), :other=>"1", :use_full_path => false}, options)
  end

  it "convert partial options for specific" do
    pretend_template_exists(true)
    options = {:partial=>"list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:partial=>"list", :other=>"1"}, options)
  end
  
  it "render partials with tabs" do
    flexstub(self) do |stub|
      stub.should_receive(:render_tabs_to_string).with(1,2,3).returns("render_result")
      stub.should_receive(:render).with(:text=>"render_result", :layout=>true)
    end
    render_partials(:tabs=>[1,2,3])
  end

  it "render partials without tabs" do
    flexstub(self) do |stub|
      stub.should_receive(:render_to_string).with({}).returns("render_result")
      stub.should_receive(:render).with(:text=>"render_result", :layout=>true)
    end
    render_partials({})
  end
  
  
end