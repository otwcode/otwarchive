require 'spec_helper'

describe CollectionProfileController do
  describe "GET #show" do
    context "collection does not exist" do
      it "redirects and provides an error message" do
        get :show, collection_id: "A non existent collection"
        expect(response).to redirect_to(collections_path)
        expect(flash[:error]).to eq "What collection did you want to look at?"
      end
    end
  end
end
