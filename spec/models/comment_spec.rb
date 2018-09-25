require 'spec_helper'

describe Comment do

  context "with an existing comment from the same user" do
    before(:all) do
      @first_comment = create(:comment)
      attributes = %w(pseud_id commentable_id commentable_type content name email)
      @second_comment = Comment.new(
        @first_comment.attributes.slice(*attributes)
      )
    end

    it "should be invalid if exactly duplicated" do
      expect(@second_comment.valid?).to eq(false)
      expect(@second_comment.errors.keys).to include(:content)
    end

    it "should not be invalid if in the process of being deleted" do
      @second_comment.is_deleted = true
      expect(@second_comment.valid?).to eq(true)
    end
  end
end
