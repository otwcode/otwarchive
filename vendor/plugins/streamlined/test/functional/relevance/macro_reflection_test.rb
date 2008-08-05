require File.expand_path(File.join(File.dirname(__FILE__), '../../test_functional_helper'))
require 'relevance/macro_reflection'

describe "Relevance::ActiveRecord::MacroReflection" do
  it "has many" do
    assoc = Poet.reflect_on_association(:poems)
    assert_true assoc.has_many?
    assert_false assoc.has_one?
    assert_false assoc.belongs_to?
    assert_false assoc.has_and_belongs_to_many?
  end
  it "belongs to" do
    assoc = Poem.reflect_on_association(:poet)
    assert_false assoc.has_many?
    assert_false assoc.has_one?
    assert_true assoc.belongs_to?
    assert_false assoc.has_and_belongs_to_many?
  end
end