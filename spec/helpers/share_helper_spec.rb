require 'spec_helper'

describe ShareHelper do

  describe "get_embed_link_title" do
    context "for anonymous works" do

      it "should not link to a user's profile" do
        @collection = FactoryGirl.create(:collection)
        @collection.collection_preference.send("anonymous=", true)
        @collection.collection_preference.save
        @work = FactoryGirl.create(:work, :collection_names => @collection.name)
        get_embed_link_title(@work).should include("by Anonymous")
      end
    end
  end

  describe "get_embed_link_meta" do
    context "a work in a series" do
      it "should do something" do
        @work
      end
    end
  end

  describe "get_tweet_text_for_bookmark" do
    context "bookmark is a work" do
      it "should return a formatted tweet" do
        @bookmark = FactoryGirl.create(:bookmark)
        get_tweet_text_for_bookmark(@bookmark).should eq "Bookmark of #{@bookmark.bookmarkable.title} by #{@bookmark.bookmarkable.pseuds.map(&:name).join(', ')} - #{@bookmark.bookmarkable.fandoms.string}".truncate(83)
      end
    end
  end
end