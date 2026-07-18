# frozen_string_literal: true

require "spec_helper"

describe "checking fandoms for crossover" do
  let!(:meta) { create(:canonical_fandom) }
  let!(:meta2) { create(:canonical_fandom) }
  let(:fandom) { create(:canonical_fandom) }
  let(:fandom2) { create(:canonical_fandom) }

  it "returns false with empty array of tags" do
    expect(FandomCrossover.check_for_crossover([])).to eq(false)
  end

  it "returns false with one tag" do
    expect(FandomCrossover.check_for_crossover([fandom])).to eq(false)
  end

  it "returns false with a fandom and one of its synonyms" do
    syn = create(:fandom, name: "some other name", merger: fandom)
    expect(FandomCrossover.check_for_crossover([fandom, syn])).to eq(false)
  end

  it "returns false for multiple synonyms of a single fandom" do
    syn1 = create(:fandom, name: "some other name", merger: fandom)
    syn2 = create(:fandom, name: "yet one more name", merger: fandom)
    expect(FandomCrossover.check_for_crossover([syn1, syn2])).to eq(false)
  end

  it "returns false for fandoms with the same direct meta tag" do
    meta.update_attribute(:sub_tag_string, "#{fandom.name},#{fandom2.name}")
    expect(FandomCrossover.check_for_crossover([fandom, fandom2])).to eq(false)
  end

  it "returns false for fandoms with the same indirect meta tag" do
    meta3 = create(:canonical_fandom)
    fandom.update_attribute(:meta_tag_string, meta.name)
    fandom2.update_attribute(:meta_tag_string, meta2.name)
    meta3.update_attribute(:sub_tag_string, "#{meta.name},#{meta2.name}")
    expect(FandomCrossover.check_for_crossover([fandom, fandom2])).to eq(false)
  end

  it "returns true if fandoms are unrelated" do
    fandom.meta_tags << meta
    fandom2.meta_tags << meta2

    fandoms = [fandom, fandom2]
    expect(FandomCrossover.check_for_crossover(fandoms)).to eq(true)
  end

  it "returns true if missing meta-taggings" do
    expect(FandomCrossover.check_for_crossover([fandom, fandom2])).to eq(true)
  end

  context "when one tagged fandom has two unrelated meta tags" do
    before do
      fandom.update_attribute(:meta_tag_string, "#{meta.name},#{meta2.name}")
    end

    it "returns false with the fandom's synonym" do
      syn = create(:fandom, merger: fandom)
      expect(FandomCrossover.check_for_crossover([fandom, syn])).to eq(false)
    end

    it "returns false with one of the fandom's meta tag" do
      expect(FandomCrossover.check_for_crossover([fandom, meta])).to eq(false)
    end

    it "returns false with another subtag of the fandom's meta tag" do
      sub = create(:canonical_fandom)
      sub.update_attribute(:meta_tag_string, meta.name)
      expect(FandomCrossover.check_for_crossover([fandom, sub])).to eq(false)
    end

    it "returns false with another fandom sharing the same two meta tags" do
      other = create(:canonical_fandom)
      other.update_attribute(:meta_tag_string, "#{meta.name},#{meta2.name}")
      expect(FandomCrossover.check_for_crossover([fandom, other])).to eq(false)
    end

    it "returns false with another fandom with two unrelated meta tags, only one of which is shared by both fandoms" do
      # The tag fandom and the tag other share one meta tag (meta2), but
      # fandom has a meta tag meta1 completely unrelated to other, and other
      # has a meta tag meta3 completely unrelated to fandom. However, the
      # shared meta tag means that they are related, and thus a work tagged
      # with both is not a crossover.
      meta3 = create(:canonical_fandom)
      other = create(:canonical_fandom)
      other.update_attribute(:meta_tag_string, "#{meta2.name},#{meta3.name}")
      expect(FandomCrossover.check_for_crossover([fandom, other])).to eq(false)
    end

    it "returns true with another fandom with two unrelated meta tags, when none of the meta tags are shared" do
      meta3 = create(:canonical_fandom)
      meta4 = create(:canonical_fandom)
      other = create(:canonical_fandom)
      other.update_attribute(:meta_tag_string, "#{meta3.name},#{meta4.name}")
      expect(FandomCrossover.check_for_crossover([fandom, other])).to eq(true)
    end
  end
end
