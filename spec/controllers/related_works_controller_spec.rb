require 'spec_helper'

describe RelatedWorksController do
  include LoginMacros
  let(:child_creator) { FactoryGirl.create(:user) }
  let(:child_work) { FactoryGirl.create(:work, authors: [child_creator.default_pseud]) }
  let(:parent_creator) { FactoryGirl.create(:user) }
  let(:parent_work) { FactoryGirl.create(:work, authors: [parent_creator.default_pseud]) }

  describe "GET #index" do
    context "for a blank user" do
      before(:each) do
        get :index, user_id: ""
      end

      it "sets a flash message" do
        expect(flash[:error]).to eq("Whose related works were you looking for?")
      end

      it "redirects the requester" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "for a nonexistent user" do
      before(:each) do
        get :index, user_id: "user"
      end

      it "sets a flash message" do
        expect(flash[:error]).to eq("Sorry, we couldn't find that user")
      end

      it "redirects the requester" do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "PUT #update" do
    context "by the creator of the child work" do
      before(:each) do
        @related_work = FactoryGirl.create(:related_work, work_id: child_work.id)
        fake_login_known_user(child_creator)
        put :update, id: @related_work
      end

      it "sets a flash message" do
        expect(flash[:error]).to eq("Sorry, but you don't have permission to do that. Try removing the link from your own work.")
      end

      it "redirects the requester" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "by a user who is not the creator of either work" do
      before(:each) do
        @related_work = FactoryGirl.create(:related_work)
        fake_login
        put :update, id: @related_work
      end

      it "sets a flash message" do
        expect(flash[:error]).to eq("Sorry, but you don't have permission to do that.")
      end

      it "redirects the requester" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "by the creator of the parent work" do
      before(:each) do
        @related_work = FactoryGirl.create(:related_work, parent_id: parent_work.id, reciprocal: true)
        fake_login_known_user(parent_creator)
      end

      context "with valid parameters" do
        before(:each) do
          put :update, id: @related_work
        end

        it "updates the related work attributes" do
          @related_work.reload
          expect(@related_work.reciprocal?).to be false
        end

        it "sets a flash message" do
          expect(flash[:notice]).to eq("Link was successfully removed")
        end

        it "redirects to the parent work" do
          expect(response).to redirect_to @related_work.parent
        end
      end

      context "with invalid parameters" do
        xit "sets a flash message" do
          expect(flash[:notice]).to eq("Sorry, something went wrong.")
        end

        xit "redirects to the related work" do
          expect(response).to redirect_to @related_work
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "by the creator of the parent work" do
      before(:each) do
        @related_work = FactoryGirl.create(:related_work, parent_id: parent_work.id, reciprocal: true)
        fake_login_known_user(parent_creator)
        delete :destroy, id: @related_work
      end

      it "sets a flash message" do
        expect(flash[:error]).to eq("Sorry, but you don't have permission to do that. You can only approve or remove the link from your own work.")
      end

      it "redirects the requester" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "by a user who is not the creator of either work" do
      before(:each) do
        @related_work = FactoryGirl.create(:related_work)
        fake_login
        delete :destroy, id: @related_work
      end

      it "sets a flash message" do
        expect(flash[:error]).to eq("Sorry, but you don't have permission to do that.")
      end

      it "redirects the requester" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "by the creator of the child work" do
      before(:each) do
        @related_work = FactoryGirl.create(:related_work, work_id: child_work.id)
        fake_login_known_user(child_creator)
      end

      it "deletes the related work" do
        expect {
          delete :destroy, id: @related_work
        }.to change(RelatedWork, :count).by(-1)
      end

      it "redirects the requester" do
        delete :destroy, id: @related_work
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
