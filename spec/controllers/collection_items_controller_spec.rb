require 'spec_helper'

describe CollectionItemsController do
  include LoginMacros
  include RedirectExpectationHelper
  
  describe "GET #index" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      @collection = FactoryGirl.create(:collection)
      @rejectedwork = FactoryGirl.create(:work)
      @approvedwork = FactoryGirl.create(:work)
      @invitedwork = FactoryGirl.create(:work)
      @approvedwork.add_to_collection(@collection) && @approvedwork.save
      @rejectedworkitem = FactoryGirl.create(:collection_item, collection_id: @collection.id, item_id: @rejectedwork.id)
      @rejectedworkitem.collection_approval_status = -1
      @rejectedworkitem.item_type = "Work"
      @rejectedworkitem.save
      @invitedworkitem = FactoryGirl.create(:collection_item, collection_id: @collection.id, item_id: @invitedwork.id)
      @invitedworkitem.user_approval_status = 0
      @invitedworkitem.item_type = "Work"
      @invitedworkitem.save
    end

    context "where the user is not a maintainer" do
      it "redirects and shows an error message" do
        fake_login_known_user(user)
        get :index
        it_redirects_to_with_error(collections_path, "You don't have permission to see that, sorry!")
      end
    end

    context "rejected parameter for collection with items in" do
      let(:owner) { @collection.owners.first.user }
      render_views

      it "includes rejected items" do
        fake_login_known_user(owner)
        get :index, collection_id: @collection.name, rejected: true
        expect(response).to have_http_status(:success)
        expect(response.body).to include @collection.title
        expect(response.body).to include @rejectedwork.title
      end

      it "excludes approved and invited items" do
        get :index, collection_id: @collection.name, rejected: true
        expect(response.body).not_to include @approvedwork.title
        expect(response.body).not_to include @invitedwork.title
      end
    end

    context "invited parameter for collection with items in" do
      let(:owner) { @collection.owners.first.user }
      render_views

      it "includes invited items" do
        fake_login_known_user(owner)
        get :index, collection_id: @collection.name, invited: true
        expect(response).to have_http_status(:success)
        expect(response.body).to include @collection.title
        expect(response.body).to include @invitedwork.title
      end

      it "excludes approved and rejected items" do
        get :index, collection_id: @collection.name, invited: true
        expect(response.body).not_to include @approvedwork.title
        expect(response.body).not_to include @rejectedwork.title
      end
    end

    context "for collection with items in" do
      let(:owner) { @collection.owners.first.user }
      render_views

      it "includes approved items" do
        fake_login_known_user(owner)
        get :index, collection_id: @collection.name, approved: true
        expect(response).to have_http_status(:success)
        expect(response.body).to include @collection.title
        expect(response.body).to include @approvedwork.title
      end

      it "excludes invited and rejected items" do
        get :index, collection_id: @collection.name, approved: true
        expect(response.body).not_to include @invitedwork.title
        expect(response.body).not_to include @rejectedwork.title
      end
    end
  end

  describe "GET #create" do
    context "creation" do
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

  describe "#destroy" do
    before(:each) do
      @collection = FactoryGirl.create(:collection)
      @approvedwork = FactoryGirl.create(:work)
      @approvedwork.add_to_collection(@collection) && @approvedwork.save
    end

    context "destroy" do
      let(:owner) { @collection.owners.first.user }
      render_views

      it "removes things" do
        @approvedworkitem = CollectionItem.find_by_item_id(@approvedwork.id)
        fake_login_known_user(owner)
        delete :destroy, id: @approvedworkitem.id
        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to include "Item completely removed from collection"
        expect(CollectionItem.where(item_id: @approvedwork.id)).to be_empty
      end
    end
  end
end
