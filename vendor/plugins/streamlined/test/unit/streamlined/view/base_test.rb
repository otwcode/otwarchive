require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/view/base'

describe "Streamlined::View::Base" do
  class Subclass < Streamlined::View::Base; end
  
  def setup
    @base = Streamlined::View::Base.new
  end
  
  it "id fragment" do
    assert_equal "Base", @base.id_fragment
    c = Class.new(Streamlined::View::Base)
    assert_equal "Subclass", Subclass.new.id_fragment
  end
  
  it "partial" do
    assert_equal "#{STREAMLINED_TEMPLATE_ROOT}/relationships/view/_base.rhtml", @base.partial
  end
end