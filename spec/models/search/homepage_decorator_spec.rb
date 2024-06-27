require "spec_helper"

describe Homepage do
  let(:user) { create(:user) }

  describe "#readings" do
    it "includes user's toread readings" do
      reading1 = create(:reading, user: user, toread: true)
      reading2 = create(:reading, toread: true)

      homepage = Homepage.new(user)
      expect(homepage.readings).to include(reading1)
      expect(homepage.readings).not_to include(reading2)
    end

    it "excludes user's readings that are not toread" do
      reading1 = create(:reading, user: user)
      reading2 = create(:reading)

      homepage = Homepage.new(user)
      expect(homepage.readings).not_to include(reading1)
      expect(homepage.readings).not_to include(reading2)
    end

    it "includes user's toread readings for restricted works" do
      work = create(:work, restricted: true)
      reading1 = create(:reading, user: user, toread: true, work: work)
      reading2 = create(:reading, toread: true, work: work)

      homepage = Homepage.new(user)
      expect(homepage.readings).to include(reading1)
      expect(homepage.readings).not_to include(reading2)
    end

    it "includes user's toread readings for deleted works" do
      reading1 = create(:reading, :deleted_work, user: user, toread: true)
      reading2 = create(:reading, :deleted_work, toread: true)

      homepage = Homepage.new(user)
      expect(homepage.readings).to include(reading1)
      expect(homepage.readings).not_to include(reading2)
    end

    it "excludes user's toread readings for hidden works" do
      work = create(:work, hidden_by_admin: true)
      reading1 = create(:reading, user: user, toread: true, work: work)
      reading2 = create(:reading, toread: true, work: work)

      homepage = Homepage.new(user)
      expect(homepage.readings).not_to include(reading1)
      expect(homepage.readings).not_to include(reading2)
    end

    it "excludes user's toread readings for draft works" do
      work = create(:draft)
      reading1 = create(:reading, user: user, toread: true, work: work)
      reading2 = create(:reading, toread: true, work: work)

      homepage = Homepage.new(user)
      expect(homepage.readings).not_to include(reading1)
      expect(homepage.readings).not_to include(reading2)
    end
  end
end
