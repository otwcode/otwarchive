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

    context "when restrict_to_fandom and restrict_to_tag_set are both enabled" do
      let(:fandom_character) { create(:character, canonical: true) }

      before do
        create(:common_tagging, filterable: fandom, common_tag: fandom_character)
        create(:common_tagging, filterable: fandom, common_tag: non_fandom_character)
        create(:tag_set_association, tag: fandom_character, parent_tag: fandom, owned_tag_set: owned_tag_set)
      end

      let!(:challenge) do
        create(:gift_exchange,
               offer_restriction: create(:prompt_restriction,
                                         character_restrict_to_fandom: true,
                                         character_restrict_to_tag_set: true,
                                         owned_tag_sets: [owned_tag_set]))
      end

      it "marks the prompt as valid when the character is in the tag set" do
        signup = build(:challenge_signup, collection: collection)
        prompt = build(:offer,
                       tag_set: create(:tag_set, tags: [fandom, fandom_character]),
                       collection_id: collection.id,
                       challenge_signup: signup)
        expect(prompt).to be_valid
      end

      it "marks the prompt as invalid when the character is canonical in the fandom but not in the tag set" do
        other_character = create(:character, canonical: true)
        create(:common_tagging, filterable: fandom, common_tag: other_character)
        signup = build(:challenge_signup, collection: collection)
        prompt = build(:offer,
                       tag_set: create(:tag_set, tags: [fandom, other_character]),
                       collection_id: collection.id,
                       challenge_signup: signup)
        expect(prompt).not_to be_valid
      end
    end

    context "when only restrict_to_fandom is enabled (not restrict_to_tag_set)" do
      let(:fandom_character) { create(:character, canonical: true) }

      before do
        create(:common_tagging, filterable: fandom, common_tag: fandom_character)
      end

      let!(:challenge) do
        create(:gift_exchange,
               offer_restriction: create(:prompt_restriction,
                                         character_restrict_to_fandom: true,
                                         character_restrict_to_tag_set: false,
                                         owned_tag_sets: [owned_tag_set]))
      end

      it "marks the prompt as valid when the character is canonical in the fandom even if not in the tag set" do
        signup = build(:challenge_signup, collection: collection)
        prompt = build(:offer,
                       tag_set: create(:tag_set, tags: [fandom, fandom_character]),
                       collection_id: collection.id,
                       challenge_signup: signup)
        expect(prompt).to be_valid
      end
    end
  end
end
