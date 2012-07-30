require 'spec_helper'

describe UnsortedTag do

  it "should be created from a bookmark" do
    # Factory.create(:bookmark, :tag_string => "bookmark tag")
    Bookmark.create(:bookmarkable_type => "Work", :bookmarkable_id => Factory.create(:work, :posted => true).id, :pseud_id => Factory.create(:pseud).id, :tag_string => "bookmark tag")
    tag = Tag.find_by_name("bookmark tag")
    tag.should be_a(UnsortedTag)
  end

  describe "recategorize" do
    %w(Fandom Character Relationship Freeform).each do |new_type|
      it "should return a tag of type #{new_type}" do
        tag = Factory.create(:unsorted_tag)
        tag.recategorize(new_type).should be_a(new_type.constantize)
      end
    end
  end

end
