require File.expand_path(File.join(File.dirname(__FILE__), '../../test_functional_helper'))
require 'streamlined/reflection'

describe "Streamlined::Reflection" do
  include Streamlined::Reflection
  attr_accessor :model
  
  def setup
    Streamlined::ReloadableRegistry.reset
  end
  
  it "reflect on scalars" do
    self.model=Person
    hash = reflect_on_scalars
    assert_key_set([:id,:first_name,:last_name], hash)
  end
  
  it "reflect on additions" do
    self.model=Person
    hash = reflect_on_additions
    assert_key_set([:full_name], hash)
  end
  
  it "reflect on relationships" do
    self.model=Poet
    hash = reflect_on_relationships
    assert_key_set([:poems], hash)
    hash.each do |k,v|
      assert_equal k.to_s, v.name.to_s
    end
  end
  
  it "reflect on delegates dups columns from associations" do
    self.model = Poem
    hash = reflect_on_delegates
    assert_not_same hash["first_name"], Streamlined.ui_for(Poet).column(:first_name)
  end
  
  it "should only reflect on delegates to associations" do
    self.model = Poem
    assert reflect_on_delegates.keys.include?("first_name")
  end
  
  it "should not include delegates to non associations" do
    self.model = Poem
    assert_false reflect_on_delegates.keys.include?("current_time")
  end
  
end