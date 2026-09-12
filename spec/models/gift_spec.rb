require "spec_helper"

describe Gift do
  it "has a valid factory" do
    expect(build(:gift)).to be_valid
  end

  context "validation" do
    it "is invalid with a too long recipient name" do
      gift = build(:gift, recipient_name: "ab" * Gift::NAME_LENGTH_MAX)
      expect(gift).to be_invalid
      expect(gift.errors[:recipient_name]).to include("must be less than #{Gift::NAME_LENGTH_MAX} characters long.")
    end

    it "is invalid without a letter or number in the recipient name" do
      gift = build(:gift, recipient_name: "_")
      expect(gift).to be_invalid
      expect(gift.errors[:recipient_name]).to include("must contain at least one letter or number.")
    end

    it "is invalid without a recipient" do
      gift = build(:gift, recipient_name: nil, user: nil)
      expect(gift).to be_invalid
      expect(gift.errors[:base]).to include("A gift must have a recipient specified.")
    end

    context "gifting twice" do
      let!(:recipient) { create(:pseud) }
      let!(:existing_gift) { create(:gift, pseud_id: recipient.id) }

      it "is invalid if already gifted to that pseud" do
        gift = build(:gift, pseud_id: recipient.id, work: existing_gift.work)
        expect(gift).to be_invalid
        expect(gift.errors[:pseud_id]).to include("You can't give a gift to the same person twice.")
      end

      it "is invalid if already gifted to that user" do
        gift = build(:gift, pseud: create(:pseud, user: existing_gift.user), work: existing_gift.work)
        expect(gift).to be_invalid
        expect(gift.errors[:base]).to include("You seem to already have given this work to that user.")
      end
    end
  end
end
