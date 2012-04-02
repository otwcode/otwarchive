# encoding: UTF-8
require 'spec_helper'

describe Tag do

  before(:each) do
    @tag = Tag.new
  end

  it "should not be valid without a name" do
    @tag.save.should_not be_true

    @tag.name = "something or other"
    @tag.save.should be_true
  end

  it "should not be valid if too long" do
    @tag.name = "a" * 101
    @tag.save.should_not be_true
    @tag.errors[:name].join.should =~ /too long/
  end

  it "should not be valid with disallowed characters" do
    @tag.name = "bad<tag"
    @tag.save.should be_false
    @tag.errors[:name].join.should =~ /restricted characters/
  end

  context "when checking for synonym/name change" do

    context "when logged in as a regular user" do

      before do
        User.current_user = FactoryGirl.create(:user)
      end

      it "should ignore capitalisation" do
        @tag.name = "yuletide"
        @tag.save

        @tag.name = "Yuletide"
        @tag.check_synonym
        @tag.errors.should be_empty
        @tag.save.should be_true
      end

      it "should ignore accented characters" do
        @tag.name = "Amelie"
        @tag.save

        @tag.name = "Amélie"
        @tag.check_synonym
        @tag.errors.should be_empty
        @tag.save.should be_true
      end

      it "should be careful with the ß" do
        @tag.name = "Wei Kreuz"
        @tag.save

        @tag.name = "Weiß Kreuz"
        @tag.check_synonym
        @tag.errors.should be_empty
        @tag.save.should be_true
      end

      it "should not ignore punctuation" do
        @tag.name = "Snatch."
        @tag.save

        @tag.name = "Snatch"
        @tag.check_synonym
        @tag.errors.should_not be_empty
        @tag.save.should be_false
      end

      it "should not ignore whitespace" do
        @tag.name = "JohnSheppard"
        @tag.save

        @tag.name = "John Sheppard"
        @tag.check_synonym
        @tag.errors.should_not be_empty
        @tag.save.should be_false
      end
    end

    context "when logged in as an admin" do
      before do
        User.current_user = FactoryGirl.create(:admin)
      end

      it "should allow any change" do
        @tag.name = "yuletide.ssé"
        @tag.save

        @tag.name = "Yuletide ße something"
        @tag.check_synonym
        @tag.errors.should be_empty
        @tag.save.should be_true
      end

    end

  end

end
