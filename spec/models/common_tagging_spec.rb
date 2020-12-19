require "spec_helper"

describe CommonTagging do
  let!(:tag) { Freeform.create(name: "NewTag") }
  let!(:parent) { Fandom.create(name: "Fandom1", canonical: true) }
  let!(:common_tagging) { CommonTagging.create(common_tag: tag, filterable: parent) }
    
  context "destroy unwrangleable assocation for tag" do
    before do
      tag.unwrangleable = true
      tag.save
    end

    it "belonging to a single fandom is not allowed" do
      common_tagging.destroy
      expect(common_tagging.destroyed?).to be(false)
    end

    it "belonging to multiple fandoms is allowed" do
      CommonTagging.create(common_tag: tag, filterable: Fandom.create(name: "Fandom2", canonical: true))
      common_tagging.destroy
      expect(common_tagging.destroyed?).to be(true)
    end
  end
end
