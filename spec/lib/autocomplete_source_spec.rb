require 'spec_helper'
require 'autocomplete_source'

shared_examples_for "an autocompleting tag" do
  let(:auto) { described_class.new(name: "Autobot") }

  describe '#autocomplete_prefixes' do
    it "should return an array that includes the class name" do
      auto.autocomplete_prefixes.should include("autocomplete_tag_all")
    end
  end
    
  describe '#autocomplete_search_string' do
    it "should be equal to its name" do
      auto.autocomplete_search_string.should == auto.name
    end
  end
  
  describe '#autocomplete_value' do
    it "should include id and name" do
      "#{auto.id}: #{auto.name}"
    end
  end
  
  describe '#autocomplete_score' do
    it "should return zero" do
      auto.autocomplete_score.should == 0
    end
  end
  
  describe '#add_to_autocomplete' do
    it "should add itself to the autocomplete"
  end
  
  describe '#remove_from_autocomplete' do
    it "should remove itself from the autocomplete"
  end

end

shared_examples_for "an autocompletable class with a title" do
  let(:auto) { described_class.new(name: "Autobot", title: "Transformer") }

  it "should have a search string composed of its name and title" do
    auto.autocomplete_search_string.should == "Autobot Transformer"
  end

end

describe Fandom do
  it_behaves_like "an autocompleting tag"
end

describe Collection do
  it_behaves_like "an autocompletable class with a title"
end