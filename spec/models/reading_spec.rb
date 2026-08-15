require "spec_helper"

describe Reading do
  it "has a valid factory" do
    expect(create(:reading)).to be_valid
  end

  describe ".visible" do
    it "excludes readings for unposted works" do
      reading = create(:reading, work: create(:draft))
      expect(Reading.visible).not_to include(reading)
    end

    it "excludes readings for works hidden by admin" do
      reading = create(:reading, work: create(:work, hidden_by_admin: true))
      expect(Reading.visible).not_to include(reading)
    end

    it "includes readings for deleted works" do
      reading = create(:reading, :deleted_work)
      expect(Reading.visible).to include(reading)
    end

    it "includes readings for restricted works" do
      reading = create(:reading, work: create(:work, restricted: true))
      expect(Reading.visible).to include(reading)
    end

    it "includes readings for regular works" do
      reading = create(:reading)
      expect(Reading.visible).to include(reading)
    end
  end
end
