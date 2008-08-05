require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/column/addition'

describe "Streamlined::Column::Addition" do
  include Streamlined::Column
  
  it "equal" do
    a1 = Addition.new(:foo_bar, nil)
    a2 = Addition.new(:foo_bar, nil)
    a3 = Addition.new(:bar, nil)
    assert_equal a1, a2
    assert_not_equal a1, a3
  end
  
  it "name" do
    addition = Addition.new(:foo_bar, nil)
    assert_equal "foo_bar", addition.name
  end
  
  it "read only defaults to true" do
    addition = Addition.new(:foo_bar, nil)
    assert addition.read_only
  end
  
  it "render th" do
    addition = Addition.new(:foo_bar, nil)
    flexmock(addition).should_receive(:sort_image => "<img src=\"up.gif\">")
    
    expected = Builder::XmlMarkup.new
    expected.th(:class => "sortSelector", :scope => "col", :col => "foo_bar") do
      expected << "Foo Bar<img src=\"up.gif\">"
    end
    assert_equal expected.target!, addition.render_th(nil, nil)
  end
  
  it "render th with sort column" do
    addition = Addition.new(:foo_bar, nil)
    addition.sort_column = :bar_bat
    flexmock(addition).should_receive(:sort_image => "<img src=\"up.gif\">")
    
    expected = Builder::XmlMarkup.new
    expected.th(:class => "sortSelector", :scope => "col", :col => "bar_bat") do
      expected << "Foo Bar<img src=\"up.gif\">"
    end
    assert_equal expected.target!, addition.render_th(nil, nil)
  end
end