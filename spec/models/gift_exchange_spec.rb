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
  end
end
