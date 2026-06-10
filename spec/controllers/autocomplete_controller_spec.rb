require "spec_helper"

describe AutocompleteController do
  describe "tag" do
    let!(:tag1) { create(:canonical_fandom, name: "Match") }
    let!(:tag2) { create(:canonical_fandom, name: "Blargh") }

    it "returns only matching tags" do
      get :tag, params: { term: "Ma", format: :json }
      expect(JSON.parse(response.body)).to eq([{ "id" => "Match", "name" => "Match" }])
    end
  end

  describe "GET #collection_title" do
    let!(:collection_to_find) { create(:collection, title: "I am here", name: "not_here") }
    let!(:collection_not_to_find) { create(:collection, title: "Foo foo", name: "foo") }

    before do
      collection_to_find.add_to_autocomplete
      collection_not_to_find.add_to_autocomplete
    end

    context "when searching by collection name" do
      it "returns the fullname for display but only the title for the field" do
        get :collection_title, params: { term: "not", format: :json }
        expect(JSON.parse(response.body)).to eq([{ "id" => "I am here", "name" => "not_here: I am here" }])
      end
    end

    context "when searching by collection title" do
      it "returns the fullname for display but only the title for the field" do
        get :collection_title, params: { term: "am", format: :json }
        expect(JSON.parse(response.body)).to eq([{ "id" => "I am here", "name" => "not_here: I am here" }])
      end
    end

    context "when searching for name and title" do
      it "returns the fullname for display but only the title for the field" do
        get :collection_title, params: { term: "here", format: :json }
        expect(JSON.parse(response.body)).to eq([{ "id" => "I am here", "name" => "not_here: I am here" }])
      end
    end
  end
end
