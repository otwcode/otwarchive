require 'spec_helper'

describe ShareHelper do
  describe "#get_tumblr_embed_link_title" do
    context "for anonymous works" do
      it "should not link to a user's profile" do
        @work = build_stubbed(:work, in_anon_collection: true)
        expect(get_tumblr_embed_link_title(@work)).to include("by Anonymous")
      end
    end
  end

  describe "#get_tweet_text_for_bookmark" do
    context "bookmark is a work" do
      it "should return a formatted tweet" do
        bookmark = FactoryBot.create(:bookmark)
        title = bookmark.bookmarkable.title
        creators = bookmark.bookmarkable.creators.to_sentence
        fandoms = bookmark.bookmarkable.fandom_string
        text = "Bookmark of #{title} by #{creators} - #{fandoms}".truncate(83)

        expect(get_tweet_text_for_bookmark(bookmark)).to eq(text)          
      end
    end
  end
end
