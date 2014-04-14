require 'spec_helper'

describe WorksHelper do

  describe '#get_tweet_text' do

    before(:each) do
      @work = FactoryGirl.create(:work)
    end

    context "for an unrevealed work" do
      it "should say that it's a mystery work" do
        @work.in_unrevealed_collection = true
        helper.get_tweet_text(@work).should == "Mystery Work"
      end
    end

    context "for an anonymous work" do
      it "should not include the author's name" do
        @work.in_anon_collection = true
        helper.get_tweet_text(@work).should match "Anonymous"
        helper.get_tweet_text(@work).should_not match "test pseud"
      end
    end

    context "for a multifandom work" do
      it "should not try to include all the fandoms" do
        @work.fandom_string = "Testing, Battlestar Galactica, Naruto"
        helper.get_tweet_text(@work).should match "Multifandom"
        helper.get_tweet_text(@work).should_not match "Battlestar"
      end
    end

    context "for a revealed, non-anon work with one fandom" do
      it "should include all info" do
        helper.get_tweet_text(@work).should match /My title by test pseud \d* - Testing/
      end
    end

  end

end
