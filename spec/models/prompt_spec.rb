# frozen_string_literal: true

require "spec_helper"

describe Prompt do
  describe "#restricted_tags" do
    let(:fandom) { create(:fandom, canonical: true) }
    let(:non_fandom_character) { create(:character, canonical: true) }
    let(:collection) { create(:collection, challenge: challenge) }
    let(:owned_tag_set) { create(:owned_tag_set, tags: [fandom, non_fandom_character]) }

    before do
      create(:tag_set_association, tag: non_fandom_character, parent_tag: fandom, owned_tag_set: owned_tag_set)
    end

    context "when the prompt uses a non-fandom tag that is in the challenge TagSet" do
      let!(:challenge) do
        create(:gift_exchange,
               offer_restriction: create(:prompt_restriction,
                                         character_restrict_to_fandom: true, owned_tag_sets: [owned_tag_set]))
      end

      it "marks the prompt as valid" do
        prompt = build(:offer,
                       tag_set: create(:tag_set, tags: [fandom, non_fandom_character]),
                       collection_id: collection.id,
                       challenge_signup: create(:challenge_signup))
        expect(prompt).to be_valid
      end
    end

    context "when the prompt uses a non-fandom tag that is not in the challenge TagSet" do
      let!(:challenge) do
        create(:gift_exchange,
               offer_restriction: create(:prompt_restriction, character_restrict_to_fandom: true))
      end

      it "marks the prompt as invalid" do
        prompt = build(:offer,
                       tag_set: create(:tag_set, tags: [fandom, non_fandom_character]),
                       collection_id: collection.id)
        expect(prompt).not_to be_valid
        expect(prompt.errors[:base][0]).to include("not in the selected fandom")
      end
    end
  end
end
