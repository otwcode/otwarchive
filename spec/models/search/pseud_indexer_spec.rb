require "spec_helper"

describe PseudIndexer, pseud_search: true do
  describe ".index_all" do
    it "uses configured shard count when creating the index" do
      allow(PseudIndexer).to receive(:index_from_db)
      expect(PseudIndexer).to receive(:create_index).with(shards: ArchiveConfig.PSEUD_SHARDS)

      PseudIndexer.index_all
    end
  end

  describe "#index_documents" do
    let(:pseud) { create(:pseud) }
    let(:indexer) { PseudIndexer.new([pseud.id]) }

    context "when a pseud in the batch has no user" do
      before { pseud.user.delete }

      it "doesn't error" do
        expect { indexer.index_documents }.not_to raise_exception
      end
    end

    context "when there are many pseuds", :n_plus_one do
      populate do |n|
        n.times do
          creator = create(:user).default_pseud
          fandom = create(:canonical_fandom)
          create(:work, authors: [creator], fandom_string: fandom.name)
          create(:work, authors: [creator], restricted: true,
                        fandom_string: fandom.name)
          create(:bookmark, pseud_id: creator.id)
        end
      end

      it "generates a constant number of queries" do
        expect do
          PseudIndexer.new(Pseud.ids).index_documents
        end.to perform_constant_number_of_queries
      end
    end
  end

  describe "#document" do
    let(:user) { create(:user) }
    let(:pseud) { user.default_pseud }
    let(:fandom) { create(:canonical_fandom) }

    let!(:public_work) do
      create(:work, authors: [pseud], fandom_string: fandom.name)
    end
    let!(:restricted_work) do
      create(:work, authors: [pseud], restricted: true,
                    fandom_string: fandom.name)
    end
    let!(:public_bookmark) { create(:bookmark, pseud_id: pseud.id) }
    let!(:restricted_work_bookmark) do
      create(:bookmark, pseud_id: pseud.id,
                        bookmarkable: create(:work, restricted: true))
    end
    let!(:private_bookmark) do
      create(:bookmark, pseud_id: pseud.id, private: true)
    end

    let(:document) { PseudIndexer.new([pseud.id]).document(pseud) }

    it "includes counts for all works and for public works" do
      expect(document["general_works_count"]).to eq(2)
      expect(document["public_works_count"]).to eq(1)
    end

    it "includes fandom counts for all works and for public works" do
      fandoms = document["fandoms"]
      expect(fandoms).to include(
        "id" => fandom.id, "name" => fandom.name, "count" => 2
      )
      expect(fandoms).to include(
        "id_for_public" => fandom.id, "name" => fandom.name, "count" => 1
      )
    end

    it "includes bookmark counts without private bookmarks" do
      expect(document["general_bookmarks_count"]).to eq(2)
      expect(document["public_bookmarks_count"]).to eq(1)
    end

    it "matches the document generated outside of a batch" do
      expect(document).to eq(pseud.document_json)
    end
  end
end
