require "spec_helper"

describe SupportNotice do
  it "can be created" do
    expect(create(:support_notice)).to be_valid
  end

  context "unsupported type" do
    let(:support_notice_bad_type) { build(:support_notice, support_notice_type: "invalid") }

    it "is invalid if the type is unsupported" do
      expect(support_notice_bad_type.save).to be_falsey
      expect(support_notice_bad_type.errors[:support_notice_type]).not_to be_empty
    end
  end

  context "missing type" do
    let(:support_notice_bad_type) { build(:support_notice, support_notice_type: nil) }

    it "is invalid if the type is missing" do
      expect(support_notice_bad_type.save).to be_falsey
      expect(support_notice_bad_type.errors[:support_notice_type]).not_to be_empty
    end
  end

  context "missing content" do
    let(:support_notice_missing_content) { build(:support_notice, notice_content: "") }

    it "is invalid if the notice has no content" do
      expect(support_notice_missing_content.save).to be_falsey
      expect(support_notice_missing_content.errors[:notice_content]).not_to be_empty
    end
  end

  context "multiple notices" do
    let(:first_support_notice) { create(:support_notice, :active) }
    let(:second_support_notice) { build(:support_notice, :active) }

    it "deactivates other notices upon activation" do
      expect(first_support_notice.active).to be_truthy
      expect(second_support_notice.save).to be_truthy

      expect(second_support_notice.reload.active).to be_truthy
      expect(first_support_notice.reload.active).to be_falsy
    end
  end
end
