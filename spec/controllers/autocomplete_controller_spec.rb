require "spec_helper"

describe AutocompleteController do
  describe "tag" do
    let!(:tag1) { create(:fandom, name: "Match") }
    let!(:tag2) { create(:fandom, name: "Blargh") }

    it "returns only matching tags" do
      get :tag, term: "Ma", format: :json
      expect(JSON.parse(response.body)).to eq([{ "id" => "Match", "name" => "Match" }])
    end
  end
end
