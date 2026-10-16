require "spec_helper"

describe CommentDecorator do
  context "when a parent comment has been physically deleted from the database" do
    let!(:work) { create(:work) }
    let!(:chapter) { work.last_posted_chapter }
    let!(:root_comment) { create(:comment, commentable: chapter) }
    let!(:reply) { create(:comment, commentable: root_comment) }
    let!(:nested_reply) { create(:comment, commentable: reply) }

    before do
      reply.delete
    end

    it "does not raise an error" do
      expect do
        CommentDecorator.from_thread_ids([root_comment.thread])
      end.not_to raise_error
    end

    it "returns the root comment and orphaned nested reply but not the deleted comment" do
      result = CommentDecorator.from_thread_ids([root_comment.thread])
      expect(result[root_comment.id]).to be_present
      expect(result[reply.id]).to be_nil
      expect(result[nested_reply.id]).to be_present
    end
  end
end
