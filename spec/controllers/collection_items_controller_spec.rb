require 'spec_helper'

describe CollectionItemsController do
  include LoginMacros
  include RedirectExpectationHelper
  
  describe "GET #index" do
    let(:user) { FactoryGirl.create(:user) }

    context "where the user is not a maintainer" do
      it "redirects and shows an error message" do
        fake_login_known_user(user)
        get :index
        it_redirects_to_with_error(collections_path, "You don't have permission to see that, sorry!")
      end
    end

    context "create" do
      let (:collection) { FactoryGirl.create(:collection) }

      it "fails if collection names missing" do
        get :create
        it_redirects_to_with_error(root_path, "What collections did you want to add?")
      end

      it "fails if items missing" do
        get :create, collection_names: collection.name
        it_redirects_to_with_error(root_path, "What did you want to add to a collection?")
      end
    end
  end
end
