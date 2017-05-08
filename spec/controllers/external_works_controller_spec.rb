require 'spec_helper'

describe ExternalWorksController do
  describe "GET #fetch" do
    url = "http://ao3testing.dreamwidth.org/593.html"

    before(:each) do
      @external_work = FactoryGirl.create(:external_work, url: url)
    end

    context "URL that has an external work" do
      it "responds with json" do
        get :fetch, external_work_url: url, format: :json
        expect(response.content_type).to eq "application/json"
      end

      it "responds with the matching work" do
        get :fetch, external_work_url: url, format: :json
        expect(assigns(:external_work)).to eq(@external_work)
      end

      before do
        @external_work2 = FactoryGirl.create(:external_work, url: url)
      end

      it "responds with the first matching work" do
        get :fetch, external_work_url: url, format: :json
        expect(assigns(:external_work)).to eq(@external_work)
        expect(assigns(:external_work)).not_to eq(@external_work2)
      end
    end

    context "URL that does not have an external work" do
      url_2 = "http://ao3testing.dreamwidth.org"

      it "responds with json" do
        get :fetch, external_work_url: url_2, format: :json
        expect(response.content_type).to eq "application/json"
      end

      it "responds with blank" do
        get :fetch, external_work_url: url_2, format: :json
        expect(assigns(:external_work)).to be_nil
      end
    end
  end
end
