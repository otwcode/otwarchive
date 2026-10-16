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
        "general_works_count" => 10,
        "public_works_count" => 7,
        "general_bookmarked_items_count" => 10,
        "public_bookmarked_items_count" => 5,
        "challenge_type" => nil,
        "multifandom" => true,
        "open_doors" => false,
        "moderated" => false,
        "maintainer_ids" => collection.maintainers.pluck(:user_id),
        "filter_ids" => [123, 456],
        "tag" => ["foo", "bar"]
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

  describe "#approved_works_count" do
    context "when logged in" do
      before do
        allow(User).to receive(:current_user).and_return(build(:user))
      end

      it "returns the general count" do
        decorated = CollectionDecorator.decorate_from_search([collection], search_results).first
        expect(decorated.approved_works_count).to eq(10)
      end
    end

    context "when a guest" do
      it "returns the public count" do
        decorated = CollectionDecorator.decorate_from_search([collection], search_results).first
        expect(decorated.approved_works_count).to eq(7)
      end
    end
  end

  describe "#approved_bookmarked_items_count" do
    context "when logged in" do
      before do
        allow(User).to receive(:current_user).and_return(build(:user))
      end

      it "returns the general count" do
        decorated = CollectionDecorator.decorate_from_search([collection], search_results).first
        expect(decorated.approved_bookmarked_items_count).to eq(10)
      end
    end

    context "when a guest" do
      it "returns the public count" do
        decorated = CollectionDecorator.decorate_from_search([collection], search_results).first
        expect(decorated.approved_bookmarked_items_count).to eq(5)
      end
    end
  end
end
