require 'spec_helper'

describe CollectionItemsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #index" do
    let(:user) { create(:user) }
    let(:collection) { create(:collection) }

    let(:rejected_work) { create(:work, authors: [user.default_pseud]) }
    let(:rejected_work2) { create(:work, authors: [user.default_pseud]) }
    let(:approved_work) { create(:work, authors: [user.default_pseud]) }
    let(:invited_work) { create(:work, authors: [user.default_pseud]) }
    let(:awaiting_collection_approval_work) { create(:work, authors: [user.default_pseud]) }

    before(:each) do
      approved_work.add_to_collection(collection) && approved_work.save
      @approved_work_item = CollectionItem.find_by_item_id(approved_work.id)

      @rejected_by_collection_work_item = create(:collection_item, collection: collection, item: rejected_work,)
      @rejected_by_collection_work_item.update_attribute(:collection_approval_status, -1)

      @rejected_by_user_work_item = create(:collection_item, collection: collection, item: rejected_work2)
      @rejected_by_user_work_item.update_attribute(:user_approval_status, -1)

      @invited_work_item = create(:collection_item, collection: collection, item: invited_work)
      @invited_work_item.update_attribute(:user_approval_status, 0)

      @awaiting_collection_approval_work_item = create(:collection_item, collection: collection, item: awaiting_collection_approval_work)
      @awaiting_collection_approval_work_item.update_attribute(:collection_approval_status, 0)
    end

    context "with collection params" do
      context "when the user is not a maintainer" do
        it "redirects and shows an error message" do
          fake_login_known_user(user)
          get :index, params: { collection_id: collection.id }
          it_redirects_to_with_error(collections_path, "You don't have permission to see that, sorry!")
        end
      end

      context "with no additional params" do
        let(:owner) { collection.owners.first.user }

        it "includes items awaiting collection approval" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @awaiting_collection_approval_work_item
        end

        it "excludes items that are invited, approved by both parties, or rejected by the collection or user" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name }
          expect(assigns(:collection_items)).not_to include @invited_work_item
          expect(assigns(:collection_items)).not_to include @approved_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_collection_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_user_work_item
        end
      end

      context "with params[:collection_rejected]" do
        let(:owner) { collection.owners.first.user }

        it "includes items rejected by the collection" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name, collection_rejected: true }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @rejected_by_collection_work_item
        end

        it "excludes items that are invited, approved by both parties, rejected by the user, or awaiting approval from collection" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name, collection_rejected: true }
          expect(assigns(:collection_items)).not_to include @approved_work_item
          expect(assigns(:collection_items)).not_to include @invited_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_user_work_item
          expect(assigns(:collection_items)).not_to include @awaiting_collection_approval_work_item
        end
      end

      context "with params[:user_rejected]" do
        let(:owner) { collection.owners.first.user }

        it "includes items rejected by the user" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name, user_rejected: true }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @rejected_by_user_work_item
        end

        it "excludes items that are invited, approved by both parties, rejected by the collection, or awaiting approval from collection" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name, user_rejected: true }
          expect(assigns(:collection_items)).not_to include @approved_work_item
          expect(assigns(:collection_items)).not_to include @invited_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_collection_work_item
          expect(assigns(:collection_items)).not_to include @awaiting_collection_approval_work_item
        end
      end

      context "with params[:invited]" do
        let(:owner) { collection.owners.first.user }

        it "includes invited items" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name, invited: true }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @invited_work_item
        end

        it "excludes items that are approved, rejected by the collection or user, or awaiting approval from collection" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name, invited: true }
          expect(assigns(:collection_items)).not_to include @approved_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_collection_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_user_work_item
          expect(assigns(:collection_items)).not_to include @awaiting_collection_approval_work_item
        end
      end

      context "with params[:approved]" do
        let(:owner) { collection.owners.first.user }

        it "includes approved items" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name, approved: true }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @approved_work_item
        end

        it "excludes items that are invited, rejected by the collection or user, or awaiting approval from collection" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name, approved: true }
          expect(assigns(:collection_items)).not_to include @invited_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_collection_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_user_work_item
          expect(assigns(:collection_items)).not_to include @awaiting_collection_approval_work_item
        end
      end

      context "with other params" do
        let(:owner) { collection.owners.first.user }

        it "includes items awaiting collection approval" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name, fake: true }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @awaiting_collection_approval_work_item
        end

        it "excludes items that are invited, approved by both parties, or rejected by the collection or user" do
          fake_login_known_user(owner)
          get :index, params: { collection_id: collection.name, fake: true }
          expect(assigns(:collection_items)).not_to include @invited_work_item
          expect(assigns(:collection_items)).not_to include @approved_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_collection_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_user_work_item
        end
      end
    end

    context "with user params" do
      context "with no additional params" do
        it "includes invited items" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @invited_work_item
        end

        it "excludes items that are approved by both parties, rejected by the collection or user, or awaiting approval from collection" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login }
          expect(assigns(:collection_items)).not_to include @approved_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_collection_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_user_work_item
          expect(assigns(:collection_items)).not_to include @awaiting_collection_approval_work_item
        end
      end

      context "with params[:awaiting_collection]" do
        it "includes items awaiting collection approval" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login, awaiting_collection: true }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @awaiting_collection_approval_work_item
        end

        it "excludes items that are invited, approved by both parties, or rejected by the collection or user" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login, awaiting_collection: true }
          expect(assigns(:collection_items)).not_to include @invited_work_item
          expect(assigns(:collection_items)).not_to include @approved_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_collection_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_user_work_item
        end
      end

      context "with params[:collection_rejected]" do
        it "includes items rejected by the collection" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login, collection_rejected: true }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @rejected_by_collection_work_item
        end

        it "excludes items that are invited, approved by both parties, rejected by the user, or awaiting approval from collection" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login, collection_rejected: true }
          expect(assigns(:collection_items)).not_to include @approved_work_item
          expect(assigns(:collection_items)).not_to include @invited_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_user_work_item
          expect(assigns(:collection_items)).not_to include @awaiting_collection_approval_work_item
        end
      end

      context "with params[:user_rejected]" do
        it "includes items rejected by the user" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login, user_rejected: true }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @rejected_by_user_work_item
        end

        it "excludes items that are invited, approved by both parties, rejected by the collection, or awaiting approval from collection" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login, user_rejected: true }
          expect(assigns(:collection_items)).not_to include @approved_work_item
          expect(assigns(:collection_items)).not_to include @invited_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_collection_work_item
          expect(assigns(:collection_items)).not_to include @awaiting_collection_approval_work_item
        end
      end

      context "with params[:approved]" do
        it "includes approved items" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login, approved: true }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @approved_work_item
        end

        it "excludes items that are invited, rejected by the collection or user, or awaiting approval from collection" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login, approved: true }
          expect(assigns(:collection_items)).not_to include @invited_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_collection_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_user_work_item
          expect(assigns(:collection_items)).not_to include @awaiting_collection_approval_work_item
        end
      end

      context "with other params" do
        it "includes invited items" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login, fake: true }
          expect(response).to have_http_status(:success)
          expect(assigns(:collection_items)).to include @invited_work_item
        end

        it "excludes items that are approved by both parties, rejected by the collection or user, or awaiting approval from collection" do
          fake_login_known_user(user)
          get :index, params: { user_id: user.login, fake: true }
          expect(assigns(:collection_items)).not_to include @approved_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_collection_work_item
          expect(assigns(:collection_items)).not_to include @rejected_by_user_work_item
          expect(assigns(:collection_items)).not_to include @awaiting_collection_approval_work_item
        end
      end
    end
  end

  describe "GET #create" do
    context "creation" do
      let(:collection) { FactoryBot.create(:collection) }

      it "fails if collection names missing" do
        get :create, params: { collection_id: collection.id }
        it_redirects_to_with_error(root_path, "What collections did you want to add?")
      end

      it "fails if items missing" do
        get :create, params: { collection_names: collection.name, collection_id: collection.id }
        it_redirects_to_with_error(root_path, "What did you want to add to a collection?")
      end
    end
  end

  describe "#destroy" do
    before(:each) do
      @collection = FactoryBot.create(:collection)
      @approved_work = FactoryBot.create(:work)
      @approved_work.add_to_collection(@collection) && @approved_work.save
    end

    context "destroy" do
      let(:owner) { @collection.owners.first.user }

      it "removes things" do
        @approved_work_item = CollectionItem.find_by_item_id(@approved_work.id)
        fake_login_known_user(owner)
        delete :destroy, params: { id: @approved_work_item.id, work_id: @approved_work.id}
        it_redirects_to_with_notice(collection_items_path(@collection), "Item completely removed from collection " + @collection.title + ".")
        expect(CollectionItem.where(item_id: @approved_work.id)).to be_empty
      end
    end
  end

  describe "PATCH #update_multiple" do
    let(:collection) { create(:collection) }
    let(:work) { create(:work) }
    let(:item) { create(:collection_item, collection: collection, item: work) }

    let(:attributes) { { remove: "1" } }

    describe "on the user collection items page for the work's owner" do
      let(:work_owner) { work.pseuds.first.user }

      let(:params) do
        {
          user_id: work_owner.login,
          collection_items: {
            item.id => attributes
          }
        }
      end

      context "when logged out" do
        before { fake_logout }

        it "errors and redirects" do
          patch :update_multiple, params: params
          it_redirects_to_with_error(work_owner, "You don't have permission to do that, sorry!")
        end
      end

      context "when logged in as a random user" do
        before { fake_login }

        it "errors and redirects" do
          patch :update_multiple, params: params
          it_redirects_to_with_error(work_owner, "You don't have permission to do that, sorry!")
        end
      end

      context "when logged in as the collection owner" do
        before { fake_login_known_user(collection.owners.first.user) }

        it "errors and redirects" do
          patch :update_multiple, params: params
          it_redirects_to_with_error(work_owner, "You don't have permission to do that, sorry!")
        end
      end

      context "when logged in as the work's owner" do
        before { fake_login_known_user(work_owner) }

        context "setting user_approval_status" do
          let(:attributes) { { user_approval_status: CollectionItem::REJECTED } }

          it "updates the collection item and redirects" do
            patch :update_multiple, params: params
            expect(item.reload.user_approval_status).to eq(CollectionItem::REJECTED)
            it_redirects_to_with_notice(user_collection_items_path(work_owner),
                                        "Collection status updated!")
          end
        end

        context "setting remove" do
          let(:attributes) { { remove: "1" } }

          it "deletes the collection item and redirects" do
            patch :update_multiple, params: params
            expect { item.reload }.to \
              raise_exception(ActiveRecord::RecordNotFound)
            it_redirects_to_with_notice(user_collection_items_path(work_owner),
                                        "Collection status updated!")
          end
        end

        {
          collection_approval_status: CollectionItem::REJECTED,
          unrevealed: true,
          anonymous: true
        }.each_pair do |field, value|
          context "setting #{field}" do
            let(:attributes) { { field => value } }

            it "throws an error and doesn't update" do
              expect do
                patch :update_multiple, params: params
              end.to raise_exception(ActionController::UnpermittedParameters)
              expect(item.reload.send(field)).not_to eq(value)
            end
          end
        end
      end
    end

    describe "on the collection items page for the work's collection" do
      let(:params) do
        {
          collection_id: collection.name,
          collection_items: {
            item.id => attributes
          }
        }
      end

      context "when logged out" do
        before { fake_logout }

        it "errors and redirects" do
          patch :update_multiple, params: params
          it_redirects_to_with_error(collection, "You don't have permission to do that, sorry!")
        end
      end

      context "when logged in as a random user" do
        before { fake_login }

        it "errors and redirects" do
          patch :update_multiple, params: params
          it_redirects_to_with_error(collection, "You don't have permission to do that, sorry!")
        end
      end

      context "when logged in as a maintainer" do
        before { fake_login_known_user(collection.owners.first.user) }

        {
          collection_approval_status: CollectionItem::REJECTED,
          unrevealed: true,
          anonymous: true
        }.each_pair do |field, value|
          context "setting #{field}" do
            let(:attributes) { { field => value } }

            it "updates the collection item and redirects" do
              patch :update_multiple, params: params
              expect(item.reload.send(field)).to eq(value)
              it_redirects_to_with_notice(collection_items_path(collection),
                                          "Collection status updated!")
            end
          end
        end

        context "setting remove" do
          let(:attributes) { { remove: "1" } }

          it "deletes the collection item and redirects" do
            patch :update_multiple, params: params
            expect { item.reload }.to \
              raise_exception(ActiveRecord::RecordNotFound)
            it_redirects_to_with_notice(collection_items_path(collection),
                                        "Collection status updated!")
          end
        end

        context "setting user_approval_status" do
          let(:attributes) { { user_approval_status: CollectionItem::REJECTED } }

          it "throws an error and doesn't update" do
            expect do
              patch :update_multiple, params: params
            end.to raise_exception(ActionController::UnpermittedParameters)
            expect(item.reload.user_approval_status).not_to eq(CollectionItem::REJECTED)
          end
        end
      end
    end

    describe "on the collection items page for a different user" do
      let(:user) { create(:user) }
      before { fake_login_known_user(user) }

      let(:params) do
        {
          user_id: user.login,
          collection_items: {
            item.id => { user_approval_status: CollectionItem::REJECTED }
          }
        }
      end

      it "silently fails to update the collection item" do
        patch :update_multiple, params: params
        expect(item.reload.user_approval_status).not_to eq(CollectionItem::REJECTED)
        it_redirects_to_with_notice(user_collection_items_path(user),
                                    "Collection status updated!")
      end
    end

    describe "on the collection items page for a different collection" do
      let(:other_collection) { create(:collection) }
      before { fake_login_known_user(other_collection.owners.first.user) }

      let(:params) do
        {
          collection_id: other_collection.name,
          collection_items: {
            item.id => { collection_approval_status: CollectionItem::REJECTED }
          }
        }
      end

      it "silently fails to update the collection item" do
        patch :update_multiple, params: params
        expect(item.reload.collection_approval_status).not_to eq(CollectionItem::REJECTED)
        it_redirects_to_with_notice(collection_items_path(other_collection),
                                    "Collection status updated!")
      end
    end
  end
end
