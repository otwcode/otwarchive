require 'spec_helper'

describe PeopleController do

  let(:collection) { create(:collection) }

  describe "GET #index" do
    it "assigns subtitle with collection title and people" do
      get :index, params: { collection_id: collection.name }
      expect(assigns[:page_subtitle]).to eq("#{collection.title} - People")
    end
  end
end
