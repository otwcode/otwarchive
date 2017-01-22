require 'spec_helper'

describe CollectionProfileController do

  it "checks to see if the collection exists" do
    get :show, collection_id: "A non existent collection"
    expect(response).to redirect_to(collections_path)
    expect(flash[:error]).to eq "What collection did you want to look at?"
  end 
end
