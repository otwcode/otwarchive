require 'spec_helper'

describe CollectionItemsController do
  include LoginMacros
  include RedirectExpectationHelper
  
  describe "GET #index" do
    let(:user) { create(:user) }
    before(:each) do
      @collection = create(:collection)
      @rejected_work = FactoryGirl.create(:work)
      @approved_work = FactoryGirl.create(:work)
      @invited_work = FactoryGirl.create(:work)
      @approved_work.add_to_collection(@collection) && @approved_work.save
      @rejected_work_item = FactoryGirl.create(:collection_item, collection_id: @collection.id, item_id: @rejected_work.id)
      @rejected_work_item.collection_approval_status = -1
      @rejected_work_item.save
      @invited_work_item = FactoryGirl.create(:collection_item, collection_id: @collection.id, item_id: @invited_work.id)
      @invited_work_item.user_approval_status = 0
      @invited_work_item.save
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
        expect(response.body).to include @rejected_work.title
      end

      it "excludes approved and invited items" do
        get :index, collection_id: @collection.name, rejected: true
        expect(response.body).not_to include @approved_work.title
        expect(response.body).not_to include @invited_work.title
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
        expect(response.body).not_to include @approved_work.title
        expect(response.body).not_to include @rejected_work.title
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
        expect(response.body).to include @approved_work.title
      end

      it "excludes invited and rejected items" do
        get :index, collection_id: @collection.name, approved: true
        expect(response.body).not_to include @invited_work.title
        expect(response.body).not_to include @rejected_work.title
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
      @approved_work = FactoryGirl.create(:work)
      @approved_work.add_to_collection(@collection) && @approved_work.save
    end

    context "destroy" do
      let(:owner) { @collection.owners.first.user }
      render_views

      it "removes things" do
        @approved_work_item = CollectionItem.find_by_item_id(@approved_work.id)
        fake_login_known_user(owner)
        delete :destroy, id: @approved_work_item.id
        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to include "Item completely removed from collection"
        expect(CollectionItem.where(item_id: @approved_work.id)).to be_empty
      end
    end
  end
end
