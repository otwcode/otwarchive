require 'spec_helper'

describe WorksHelper do

  describe '#get_tweet_text' do

    before(:each) do
      @work = FactoryGirl.create(:work)
    end

    context "for an unrevealed work" do
      it "should say that it's a mystery work" do
        @work.in_unrevealed_collection = true
        expect(helper.get_tweet_text(@work)).to eq("Mystery Work")
      end
    end

    context "for an anonymous work" do
      it "should not include the author's name" do
        @work.in_anon_collection = true
        expect(helper.get_tweet_text(@work)).to match "Anonymous"
        expect(helper.get_tweet_text(@work)).not_to match "test pseud"
      end
    end

    context "for a multifandom work" do
      it "should not try to include all the fandoms" do
        @work.fandom_string = "Testing, Battlestar Galactica, Naruto"
        expect(helper.get_tweet_text(@work)).to match "Multifandom"
        expect(helper.get_tweet_text(@work)).not_to match "Battlestar"
      end
    end

    context "for a revealed, non-anon work with one fandom" do
      it "should include all info" do
        expect(helper.get_tweet_text(@work)).to eq("My title is long enough by #{@work.pseuds.first.name} - Testing")
      end
    end

  end

end
