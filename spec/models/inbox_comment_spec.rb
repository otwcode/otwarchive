require "spec_helper"

RSpec.describe InboxComment, type: :model do
  describe "ID column" do
    it "can have an id larger than unsigned int" do
      new_id = 5_294_967_295

      inbox_comment = create(:inbox_comment)
      inbox_comment.update_column(:id, new_id)

      inbox_comment.reload
      expect(inbox_comment.id).to eq(new_id)
    end
  end
end
