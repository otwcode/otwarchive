require File.dirname(__FILE__) + '/../../test_helper'
require 'relevance/symbol_additions'

describe "Relevance::SymbolAdditions" do
  it "titleize" do
    assert_equal "Foo", :foo.titleize
    assert_equal "Foo Bar", :foo_bar.titleize
  end
end
