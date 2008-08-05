require File.expand_path(File.join(File.dirname(__FILE__), '../../test_functional_helper'))
require 'streamlined/helpers/link_helper'

describe "Streamlined::HelperFunctional" do
  fixtures :people
  def setup
    stock_controller_and_view
  end

  it "invisible link to" do
    assert_equal '<a href="/people/show/1" style="display:none;"></a>', @view.invisible_link_to(:action=>"show", :id=>1)
  end
  
  it "views expose controller render methods" do 
    render_methods = ['render_partials', 'render_tabs']
    assert_equal_sets render_methods, @view.methods & render_methods
  end
  
end