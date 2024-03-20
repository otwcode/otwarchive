require "spec_helper"

describe GiftExchange do
  it do
    is_expected.to validate_numericality_of(:requests_num_required)
      .is_greater_than_or_equal_to(1)
      .only_integer
  end

  it do
    is_expected.to validate_numericality_of(:offers_num_required)
      .is_greater_than_or_equal_to(1)
      .only_integer
  end

  describe "#save" do
    let(:challenge) { build(:gift_exchange) }

    it "succeeds with a valid gift exchange" do
      expect(challenge.save).to be_truthy
    end

    context "when allowed offers is bellow required offers" do
      before do
        challenge.offers_num_allowed = challenge.requests_num_required - 1
      end

      it "sets allowed offers to the same number as required" do
        challenge.save!
        expect(challenge.offers_num_allowed).to eq(challenge.offers_num_required)
      end
    end

    context "when allowed requests is below required requests" do
      before do
        challenge.requests_num_allowed = challenge.requests_num_required - 1
      end

      it "sets allowed requests to same number as required" do
        challenge.save!
        expect(challenge.requests_num_allowed).to eq(challenge.requests_num_required)
      end
    end
  end
end
