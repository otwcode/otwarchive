# frozen_string_literal: true

require "spec_helper"

describe DateHelper do
  describe "#date_in_zone" do
    let(:time) { Time.rfc3339("1999-12-31T16:00:00Z") }
    let(:zone_tokyo) { Time.find_zone("Asia/Tokyo") }

    it "is html safe" do
      expect(helper.date_in_zone(time).html_safe?).to eq(true)
    end

    it "formats UTC date without timezone identifier" do
      expect(strip_tags(helper.date_in_zone(time, zone_tokyo))).to eq("Sat 01 Jan 2000")
    end
  end

  describe "#date_in_user_time_zone" do
    let(:time) { Time.rfc3339("1999-12-31T16:00:00Z") }
    let(:user) { User.new }

    before(:each) do
      allow(helper).to receive(:logged_in?).and_return(true)
      allow(helper).to receive(:current_user).and_return(user)
    end

    it "returns the date in the user's time zone if valid" do
      allow(user).to receive(:time_zone).and_return("Asia/Tokyo")
      expect(helper.date_in_user_time_zone(time).to_s).to eq("2000-01-01 01:00:00 +0900")
    end

    it "handles errors" do
      allow(user).to receive(:time_zone).and_return("Not a real time zone")
      expect(helper.date_in_user_time_zone(time)).to eq(time)
    end
  end
end
