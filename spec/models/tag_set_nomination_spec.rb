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

    context "when a concurrent update adds a fandom beyond the limit" do
      before do
        owned_tag_set.update_column(:fandom_nomination_limit, 2)
      end

      it "rejects the second update" do
        fandom_a = FandomNomination.create!(tag_set_nomination: nomination, tagname: "Fandom A")
        # Simulate tab 1 saving a second fandom while tab 2 is still open
        FandomNomination.create!(tag_set_nomination: nomination, tagname: "Fandom B")
        nomination.reload

        # Tab 2 submits with the original fandom + a new one (it never saw Fandom B)
        result = nomination.update(
          fandom_nominations_attributes: {
            "0" => { tagname: "Fandom A", id: fandom_a.id },
            "1" => { tagname: "Fandom C" }
          }
        )

        expect(result).to be_falsey
        expect(nomination.errors[:base]).to include("You can only nominate 2 fandom tags")
      end
    end

  end
end
