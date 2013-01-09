# -*- coding: utf-8 -*-

require 'string_cleaner'

class Foo
  include StringCleaner
end

describe Foo do
  let(:foo) { Foo.new }

  describe "#remove_articles_from_string" do
    it "should remove 'the '" do
      foo.remove_articles_from_string("The Hobbit").should == "Hobbit"
    end

    it "should remove 'a '" do
      foo.remove_articles_from_string("A Song of Ice And Fire").should == "Song of Ice And Fire"
    end

    it "should remove 'an '" do
      foo.remove_articles_from_string("An Opportunity").should == "Opportunity"
    end

    it "should not remove 'the' if followed by other characters" do
      foo.remove_articles_from_string("There Will Be Blood").should == "There Will Be Blood"
    end

  end

end
