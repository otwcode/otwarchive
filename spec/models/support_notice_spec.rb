require 'spec_helper'

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

  context "missing content" do
    let(:support_notice_missing_content) { build(:support_notice, content: "") }

    it "is invalid if the notice has no content" do
      expect(support_notice_missing_content.save).to be_falsey
      expect(support_notice_missing_content.errors[:content]).not_to be_empty
    end
  end
end
