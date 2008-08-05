require File.expand_path(File.join(File.dirname(__FILE__), '../../../test_helper'))
require 'streamlined/ui/deprecated'

describe "Streamlined::Deprecated" do
  include Streamlined::DeprecatedUIClassMethods
  
  it "deprecated class methods" do
    methods = deprecated_class_methods
    assert methods.is_a?(Set)
    assert methods.size > 5
  end
  
  it "deprecated class methods dont get reassigned if already set" do
    @deprecated_class_methods = :foo
    assert_equal :foo, deprecated_class_methods
  end
end