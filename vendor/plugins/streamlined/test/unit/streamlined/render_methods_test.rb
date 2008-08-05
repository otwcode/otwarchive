require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))
require 'streamlined/render_methods'

describe "Streamlined::RenderMethods#specific_template_exists" do
  include Streamlined::RenderMethods
  
  it "specific template exists?" do
    assert specific_template_exists?("templates/template")
    assert specific_template_exists?("templates/haml_template")
    assert specific_template_exists?("templates/template.rhtml")
    assert specific_template_exists?("templates/template.rxml")
    assert !specific_template_exists?("templates/template.rpdf")
    assert !specific_template_exists?("templates/non_existing_template")
  end
  
  # partials are view/controller specific and are tested separately

end

describe 'Streamlined::RenderMethods#convert_action_options' do
  include Streamlined::RenderMethods
  
  before do
    self.stubs(:managed_views).returns(['new'])
    self.stubs(:controller_path).returns("people")
  end
  
  it "convert action options for a streamlined generic view without layout" do
    options = {:action=>"new", :id=>"1"}
    expected = {
      :file=>generic_view("new"), 
      :id=>"1", 
      :layout => true, 
      :use_full_path => false
    }
    convert_action_options(options).should == expected
  end

  it "convert action options for a streamlined generic view with layout" do
    options = {:action=>"new", :id=>"1", :layout => "cool"}
    expected = {
      :file=>generic_view("new"), 
      :id=>"1", 
      :layout => "cool", 
      :use_full_path => false
    }
    convert_action_options(options).should == expected
  end
  
  it "convert action options for a non-streamlined view is a no-op" do
    options = {:action=>"foo", :id=>"1"}
    convert_action_options(options).should.be(options)
  end
  
end
