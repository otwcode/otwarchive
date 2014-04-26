require 'spec_helper'

describe UnsortedTag do
  before do
    # TODO: this should be using factories!
    # but also, factories should actually work and not give "validation failed, login already taken"
    @creator = User.new(:terms_of_service => '1', :age_over_13 => '1')
    @creator.login = "Creator"; @creator.email = "creator@muse.net"
    @creator.save
    @bookmarker = User.new(:terms_of_service => '1', :age_over_13 => '1')
    @bookmarker.login = "Bookmarker"; @bookmarker.email = "bookmarker@avidfan.net"
    @bookmarker.save
    # TODO: use the factory when it stops giving stack too deep errors
    @chapter = Chapter.new(:content => "Whatever 10 characters", :authors => [@creator.pseuds.first])
    @work = Work.new(:title => "Work", :fandom_string => "Whatever", :authors => [@creator.pseuds.first], :chapters => [@chapter])
    @work.posted = true
    @work.save
  end

  it "should be created from a bookmark" do
    Bookmark.create(:bookmarkable_type => "Work", :bookmarkable_id => @work.id, :pseud_id => @bookmarker.pseuds.first.id, :tag_string => "bookmark tag")
    tag = Tag.find_by_name("bookmark tag")
    tag.should be_a(UnsortedTag)
  end

  describe "recategorize" do
    %w(Fandom Character Relationship Freeform).each do |new_type|
      it "should return a tag of type #{new_type}" do
        tag = FactoryGirl.create(:unsorted_tag)
        tag.recategorize(new_type).should be_a(new_type.constantize)
      end
    end
  end

end
