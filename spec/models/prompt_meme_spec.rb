require "spec_helper"

describe PromptMeme do
  describe "reindexing" do
    let!(:collection) { create(:collection) }

    context "when prompt meme is created" do
      it "enqueues the collection for reindex" do
        expect do
          PromptMeme.create!(collection: collection)
        end.to add_to_reindex_queue(collection, :main)
      end
    end

    context "when prompt meme already exists" do
      let!(:exchange) { create(:prompt_meme, collection: collection, signup_open: false) }

      context "when prompt meme signups are opened" do
        it "enqueues the collection for reindex" do
          expect do
            exchange.update!(signup_open: true)
          end.to add_to_reindex_queue(collection, :main)
        end
      end

      context "when prompt meme is not significantly changed" do
        it "doesn't enqueue the collection for reindex" do
          expect do
            exchange.update!(signup_instructions_general: "Changed text")
          end.to not_add_to_reindex_queue(collection, :main)
        end
      end

      context "when prompt meme is destroyed" do
        it "enqueues the collection for reindex" do
          expect do
            exchange.destroy!
          end.to add_to_reindex_queue(collection, :main)
        end
      end
    end
  end
end
