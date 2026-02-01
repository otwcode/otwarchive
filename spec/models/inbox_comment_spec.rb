require "spec_helper"

describe InboxComment do
  describe "#feedback_comment" do
    it "can have an id larger than unsigned int" do
      comment = create(:comment, id: 5_294_967_295)
      inbox_comment = create(:inbox_comment, feedback_comment: comment)
      expect(inbox_comment).to be_valid
      expect(inbox_comment.save).to be_truthy
      expect(inbox_comment.feedback_comment).to eq(comment)
    end
  end
end
