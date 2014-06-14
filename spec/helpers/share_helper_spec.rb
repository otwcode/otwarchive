require 'spec_helper'

describe ShareHelper do

  describe "get_embed_link_title" do
    let(:current_user) { FactoryGirl.create(:user) }
    context "for anonymous works" do
      it "should not link to a user's profile" do
        @work = FactoryGirl.create(:work, :in_anon_collection => true)
        get_embed_link_title(@work).should eq "Anonymous"
      end
    end
  end

  describe "get_tweet_text_for_bookmark" do
    context "bookmark is a work" do
      @bookmark = FactoryGirl.create(:bookmark)
      get_tweet_text_for_bookmark(@bookmark).should eq "Bookmark of #{@bookmark.bookmarkable.title} by #{@bookmark.bookmarkable.pseuds.map(&:name).join(', ')} - #{@bookmark.bookmarkable.fandoms.string}".truncate(83)
    end
  end
end