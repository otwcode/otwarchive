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

    context "when allowed offers is bellow required offers" do
      before do
        challenge.offers_num_allowed = challenge.requests_num_required - 1
      end

      it "sets allowed offers to the same number as required" do
        challenge.save!
        expect(challenge.offers_num_allowed).to eq(challenge.offers_num_required)
      end
    end

    context "when allowed requests is below required requests" do
      before do
        challenge.requests_num_allowed = challenge.requests_num_required - 1
      end

      it "sets allowed requests to same number as required" do
        challenge.save!
        expect(challenge.requests_num_allowed).to eq(challenge.requests_num_required)
      end
    end
  end

  describe "reindexing" do
    let!(:collection) { create(:collection) }

    context "when gift exchange is created" do
      it "enqueues the collection for reindex" do
        expect do
          GiftExchange.create!(collection: collection)
        end.to add_to_reindex_queue(collection, :main)
      end
    end

    context "when gift exchange already exists" do
      let!(:exchange) { create(:gift_exchange, collection: collection, signup_open: false) }

      context "when gift exchange signups are opened" do
        it "enqueues the collection for reindex" do
          expect do
            exchange.update!(signup_open: true)
          end.to add_to_reindex_queue(collection, :main)
        end
      end

      context "when gift exchange is not significantly changed" do
        it "doesn't enqueue the collection for reindex" do
          expect do
            exchange.update!(signup_instructions_general: "Changed text")
          end.to not_add_to_reindex_queue(collection, :main)
        end
      end

      context "when gift exchange is destroyed" do
        it "enqueues the collection for reindex" do
          expect do
            exchange.destroy!
          end.to add_to_reindex_queue(collection, :main)
        end
      end
    end
  end
end
