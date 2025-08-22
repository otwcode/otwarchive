require "spec_helper"

describe PseudIndexer, pseud_search: true do
  describe "#index_documents" do
    let(:pseud) { create(:pseud) }
    let(:indexer) { PseudIndexer.new([pseud.id]) }

    context "when a pseud in the batch has no user" do
      before { pseud.user.delete }

      it "doesn't error" do
        expect { indexer.index_documents }
          .not_to raise_exception
      end
    end

    context "when there are many pseuds", :n_plus_one do
      populate { |n| create_list(:pseud, n) }

      it "generates a constant number of database queries" do
        expect do
          PseudIndexer.new(Pseud.ids).index_documents
        end.to perform_constant_number_of_queries

        expect { indexer.index_documents }
          .not_to raise_exception
      end
    end
  end
end
