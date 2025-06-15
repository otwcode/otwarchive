# frozen_string_literal: true

require "spec_helper"

describe TagNomination do
  describe "#set_parented" do
    context "when the nominated tag is a freeform" do
      let(:nomination) { create(:tag_nomination, type: "FreeformNomination", tagname: generate(:tag_name)) }

      it "sets parented to true" do
        expect(nomination.parented).to be(true)
      end
    end

    context "when the nominated tag does not already exist" do
      let(:nomination) { create(:tag_nomination, tagname: generate(:tag_name)) }

      it "sets parented to false" do
        expect(nomination.parented).to be(false)
      end
    end

    context "when the nominated tag already exists" do
      let(:nomination) { create(:tag_nomination, tagname: character.name, type: "CharacterNomination") }

      context "when the tag is non-canonical" do
        let(:character) { create(:character) }

        it "sets parented to false" do
          expect(nomination.parented).to be(false)
        end
      end

      context "when the tag is canonical" do
        context "when the tag has a known parent" do
          let(:fandom) { create(:canonical_fandom) }
          let(:character) { create(:canonical_character) }

          before do
            create(:common_tagging, filterable: fandom, common_tag: character)
          end

          it "sets parented to true" do
            expect(nomination.parented).to be(true)
          end

          context "when the nomination has a parent that matches a known parent" do
            let(:nomination) { create(:tag_nomination, tagname: character.name, type: "CharacterNomination", parent_tagname: fandom.name) }

            it "sets parented to true" do
              expect(nomination.parented).to be(true)
            end
          end

          context "when the nomination has a parent that does not match a known parent" do
            let(:nomination) { create(:tag_nomination, tagname: character.name, type: "CharacterNomination", parent_tagname: generate(:tag_name)) }

            it "sets parented to false" do
              expect(nomination.parented).to be(false)
            end
          end
        end
      end
    end
  end
end
