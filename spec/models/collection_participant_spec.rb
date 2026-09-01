require "spec_helper"

describe CollectionParticipant do
  describe "validations" do
    it "does not allow the removed Invited role" do
      participant = build(:collection_participant, participant_role: "Invited")
      expect(participant).to be_invalid
      expect(participant.errors[:participant_role]).to include("That is not a valid participant role.")
    end
  end
end
