require File.dirname(__FILE__) + '/../../test_helper'
require 'relevance/string_additions'

describe "Relevance::StringAdditions" do
  it "const for name" do
    assert_equal String, 'String'.to_const
    assert_equal String, '::String'.to_const
    assert_equal false, 'Flibberty'.to_const
    assert_equal :custom, 'Flibberty'.to_const(:custom)
    assert_equal false, 'String::Flibberty'.to_const
  end
  
  it "variableize" do
    assert_equal "this_works", "this::works".variableize
    assert_equal "this_works_too", "this/works/too".variableize
  end
end
