require "spec_helper"

describe InboxComment do
  describe "#id" do
    it "can be larger than unsigned int" do
      inbox_comment = build(:inbox_comment, id: 5_294_967_295)
      expect(inbox_comment).to be_valid
      expect(inbox_comment.save).to be_truthy
    end
  end

  describe "#feedback_comment" do
    it "can have an id larger than unsigned int" do
      comment = create(:comment, id: 5_294_967_295)
      inbox_comment = build(:inbox_comment, feedback_comment: comment)
      expect(inbox_comment).to be_valid
      expect(inbox_comment.save).to be_truthy
      expect(inbox_comment.feedback_comment).to eq(comment)
    end
  end
end
