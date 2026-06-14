require 'spec_helper'

describe TagSetNomination do

  describe "save" do

    before(:each) do
      @tag_set_nomination = FactoryBot.create(:tag_set_nomination)
    end

    it "should save a basic tag set nomination" do
      expect(@tag_set_nomination.save).to be_truthy
    end

  end

  describe "#nomination_limits" do
    let(:owned_tag_set) { create(:owned_tag_set) }
    let(:nomination) { create(:tag_set_nomination, owned_tag_set: owned_tag_set) }

    context "when fandom nominations exceed the limit via update" do
      before do
        owned_tag_set.update_column(:fandom_nomination_limit, 2)
      end

      it "rejects adding a fandom beyond the limit" do
        fandom_a = FandomNomination.create!(tag_set_nomination: nomination, tagname: "Fandom A")
        fandom_b = FandomNomination.create!(tag_set_nomination: nomination, tagname: "Fandom B")
        nomination.reload

        result = nomination.update(
          fandom_nominations_attributes: {
            "0" => { tagname: "Fandom A", id: fandom_a.id },
            "1" => { tagname: "Fandom B", id: fandom_b.id },
            "2" => { tagname: "Fandom C" }
          }
        )

        expect(result).to be_falsey
        expect(nomination.errors[:base]).to include("You can only nominate 2 fandom tags")
      end
    end

    context "when character nominations exceed the limit via update" do
      before do
        owned_tag_set.update_column(:fandom_nomination_limit, 1)
        owned_tag_set.update_column(:character_nomination_limit, 2)
      end

      it "rejects adding a character beyond the limit" do
        fandom_nom = FandomNomination.create!(tag_set_nomination: nomination, tagname: "Test Fandom")
        CharacterNomination.create!(tag_set_nomination: nomination, fandom_nomination: fandom_nom, tagname: "Char A")
        CharacterNomination.create!(tag_set_nomination: nomination, fandom_nomination: fandom_nom, tagname: "Char B")
        nomination.reload

        result = nomination.update(
          fandom_nominations_attributes: {
            "0" => {
              id: fandom_nom.id,
              tagname: "Test Fandom",
              character_nominations_attributes: {
                "0" => { tagname: "Char A", id: fandom_nom.character_nominations.first.id, from_fandom_nomination: true },
                "1" => { tagname: "Char B", id: fandom_nom.character_nominations.second.id, from_fandom_nomination: true },
                "2" => { tagname: "Char C", from_fandom_nomination: true }
              }
            }
          }
        )

        expect(result).to be_falsey
        expect(nomination.errors[:base]).to include("You can only nominate 2 character tags per fandom.")
      end
    end
  end
end
