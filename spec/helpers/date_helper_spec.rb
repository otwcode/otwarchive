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
end
