require 'spec_helper'

describe RelatedWorksController do
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
end
