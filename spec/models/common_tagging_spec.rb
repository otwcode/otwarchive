require "spec_helper"

describe CommonTagging do
  before(:each) do
    @tag = Freeform.create(name: "NewTag")
    @parent = Fandom.create(name: "Fandom1", canonical: true)
    @common_tagging = CommonTagging.create(common_tag: @tag, filterable: @parent)
  end

  context 'destroy unwrangleable assocation for tag' do
    before(:each) do
      @tag.unwrangleable = true
      @tag.save
    end

    it 'belonging to a single fandom is not allowed' do
      @common_tagging.destroy
      expect(@common_tagging.destroyed?).to be(false)
    end

    it 'belonging to multiple fandoms is allowed' do
      CommonTagging.create(common_tag: @tag, filterable: Fandom.create(name: "Fandom2", canonical: true))
      expect(@tag.parents.by_type("Fandom").size).to be(2)
      @common_tagging.destroy
      expect(@common_tagging.destroyed?).to be(true)
    end
  end
end