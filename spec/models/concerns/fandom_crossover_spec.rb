# frozen_string_literal: true

require 'spec_helper'

describe "checking fandoms for crossover" do
  let!(:meta) { create(:canonical_fandom) }
  let!(:meta2) { create(:canonical_fandom) }
  let(:fandom) { create(:canonical_fandom) }
  let(:fandom2) { create(:canonical_fandom) }

  it "Returns false with empty array of tags" do
    expect(FandomCrossover.new.check_for_crossover([])).to eq(false)
  end

  it "Returns false with one tag" do
    expect(FandomCrossover.new.check_for_crossover([fandom])).to eq(false)
  end

  it "returns true if fandoms are unrelated" do
    fandom.meta_tags << meta
    fandom2.meta_tags << meta2

    fandoms = [fandom, fandom2]
    expect(FandomCrossover.new.check_for_crossover(fandoms)).to eq(true)
  end
end
