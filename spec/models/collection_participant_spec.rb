require "spec_helper"

describe CollectionParticipant do
  describe "#participant_role" do
    let(:participant) { build(:collection_participant) }

    it "is invalid with the removed Invited role" do
      participant.participant_role = "Invited"
      participant.valid?
      expect(participant.errors[:participant_role])
        .to include("That is not a valid participant role.")
    end

    it "accepts the None role" do
      participant.participant_role = CollectionParticipant::NONE
      participant.valid?
      expect(participant.errors[:participant_role]).to be_empty
    end

    it "accepts the Owner role" do
      participant.participant_role = CollectionParticipant::OWNER
      participant.valid?
      expect(participant.errors[:participant_role]).to be_empty
    end

    it "accepts the Moderator role" do
      participant.participant_role = CollectionParticipant::MODERATOR
      participant.valid?
      expect(participant.errors[:participant_role]).to be_empty
    end

    it "accepts the Member role" do
      participant.participant_role = CollectionParticipant::MEMBER
      participant.valid?
      expect(participant.errors[:participant_role]).to be_empty
    end
  end
end
