require 'spec/spec_helper'

describe ThinkingSphinx::Collection do
  it "should return items paired to their attribute values" do
    results = Person.search ""
    results.should_not be_empty
    results.each_with_sphinx_internal_id do |result, id|
      result.id.should == id
    end
  end
  
  it "should return items paired with their weighting" do
    results = Person.search "Ellie Ford", :match_mode => :any
    results.should_not be_empty
    results.each_with_weighting do |result, weight|
      result.should be_kind_of(Person)
      weight.should be_kind_of(Integer)
    end
  end
  
  it "should return items paired with their count if grouping" do
    results = Person.search :group_function => :attr, :group_by => "birthday"
    results.should_not be_empty
    results.each_with_count do |result, count|
      result.should be_kind_of(Person)
      count.should  be_kind_of(Integer)
    end
  end
  
  it "should return items paired with their count and group value" do
    results = Person.search :group_function => :attr, :group_by => "birthday"
    results.should_not be_empty
    results.each_with_group_and_count do |result, group, count|
      result.should be_kind_of(Person)
      # sometimes the grouping value will be nil/null
      group.should  be_kind_of(Integer) unless group.nil?
      count.should  be_kind_of(Integer)
    end
  end
  
  it "should return ids" do
    results = Person.search_for_ids "Ellie"
    results.should_not be_empty
    results.each do |result|
      result.should be_kind_of(Integer)
    end
  end
  
  it "should return ids paired with weighting" do
    results = Person.search_for_ids "Ellie Ford", :match_mode => :any
    results.should_not be_empty
    results.each_with_weighting do |result, weight|
      result.should be_kind_of(Integer)
      weight.should be_kind_of(Integer)
    end
  end
  
  it "should sort the objects the same as the result set" do
    Person.search_for_ids("Ellie", :order => "sphinx_internal_id DESC").should ==
    Person.search("Ellie", :order => "sphinx_internal_id DESC").collect(&:id)
  end
end