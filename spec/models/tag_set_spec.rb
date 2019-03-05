# encoding: utf-8
require 'spec_helper'

describe TagSet do
  describe "find_type_label" do
    it "should translate the correct label for archive warnings" do
      expect(TagSet.find_type_label("archive_warning")).to eq("warning")
    end

    it "should translate default labels for other tag types" do
      [:fandom, :character, :relationship, :freeform, :category, :rating].each do |tag_type|
        expect(TagSet.find_type_label(tag_type)).to eq(tag_type.to_s)
      end
    end

    it "should raise an error if tag type doesn't exists" do
      expect { TagSet.find_type_label("does_not_exists") }.to raise_error("Tag label doesn't exist for that type")
    end
  end
end
