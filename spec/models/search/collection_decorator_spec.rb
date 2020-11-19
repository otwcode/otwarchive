require "spec_helper"

describe CollectionDecorator do
  
  let!(:collection) { create(:collection) }
  let!(:search_results) do
    [{
      "_id" =>
      collection.id.to_s,
      "_source" => {
        "id" => collection.id.to_s,
        "name" => collection.name,
        "title" => collection.title,
        "description" => nil,
        "created_at" => collection.created_at.to_s,
        "parent_id" => nil,
        "closed" => false,
        "unrevealed" => false,
        "anonymous" => false,
        "owner_ids" => collection.all_owners.pluck(:id),
        "moderator_ids" => [],
        "signup_open" => nil,
        "signups_open_at" => nil,
        "signups_close_at" => nil,
        "assignments_due_at" => nil,
        "works_reveal_at" => nil,
        "authors_reveal_at" => nil,
        "general_fandom_ids" => [],
        "public_fandom_ids" => [],
        "general_fandoms_count" => 5,
        "public_fandoms_count" => 10,
        "general_works_count" => 7,
        "public_works_count" => 10,
        "general_bookmarked_items_count" => 5,
        "public_bookmarked_items_count" => 10
      }
    }]
  end

  describe ".decorate_from_search" do
    it "initializes decorators" do
      decs = CollectionDecorator.decorate_from_search([collection], search_results)
      expect(decs.length).to eq(1)
      expect(decs.first.title).to eq(collection.title)
    end
  end

  context "with search data" do
    let!(:decorator) { CollectionDecorator.decorate_from_search([collection], search_results).first }    

    describe "#works_count" do
      it "returns the public works count if there's no current user" do
        expect(decorator.works_count).to eq(10)
      end

      it "returns the general works count if there is a current user" do
        User.current_user = User.new
        expect(decorator.works_count).to eq(7)
      end
    end

    describe "#bookmarks_count" do
      it "returns the public count if there's no current user" do
        expect(decorator.bookmarks_count).to eq(10)
      end

      it "returns the general count if there is a current user" do
        User.current_user = User.new
        expect(decorator.bookmarks_count).to eq(5)
      end
    end

    describe "#fandoms_count" do
      it "returns the public fandoms count if there's no current user" do
        expect(decorator.bookmarks_count).to eq(10)
      end

      it "returns the general fandoms count if there is a current user" do
        User.current_user = User.new
        expect(decorator.bookmarks_count).to eq(5)
      end
    end
  end
end
