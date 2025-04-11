# frozen_string_literal: true

require "spec_helper"

describe Prompt do
  describe "validations" do
    context "when the prompt uses a non-fandom tag that is not in the challenge TagSet" do
      let(:fandom) { create(:fandom, canonical: true) }
      let(:non_fandom_character) { create(:character, canonical: true) }
      let(:collection) { create(:collection, challenge: challenge) }

      let!(:challenge) do
        create(:gift_exchange,
               offer_restriction: create(:prompt_restriction, character_restrict_to_fandom: true))
      end

      it "marks the prompt as invalid" do
        create(:owned_tag_set, tags: [fandom, non_fandom_character])
        create(:tag_set_association, tag: non_fandom_character, parent_tag: fandom)
        prompt = build(:offer,
                       tag_set: create(:tag_set, tags: [fandom, non_fandom_character]),
                       collection_id: collection.id)
        expect(prompt).not_to be_valid
        expect(prompt.errors[:base][0]).to include("not in the selected fandom")
      end
    end
  end
end
