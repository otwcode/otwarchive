require 'spec_helper'

describe ExternalWorksController do
  describe "GET #fetch" do
    let(:url) { "http://example.org/200" }

    before { WebMock.stub_request(:any, url) }

    context "when the URL has an external work" do
      let!(:external_work) { create(:external_work, url: url) }

      it "responds with json" do
        get :fetch, params: { external_work_url: url, format: :json }
        expect(response.content_type).to match("application/json")
      end

      it "responds with the matching work" do
        get :fetch, params: { external_work_url: url, format: :json }
        expect(assigns(:external_work)).to eq(external_work)
      end

      context "when the URL has a second external work" do
        let!(:external_work2) { create(:external_work, url: url) }

        it "responds with the first matching work" do
          get :fetch, params: { external_work_url: url, format: :json }
          expect(assigns(:external_work)).to eq(external_work)
          expect(assigns(:external_work)).not_to eq(external_work2)
        end
      end
    end

    context "when the URL doesn't have an exteral work" do
      it "responds with json" do
        get :fetch, params: { external_work_url: url, format: :json }
        expect(response.content_type).to match("application/json")
      end

      it "responds with blank" do
        get :fetch, params: { external_work_url: url, format: :json }
        expect(assigns(:external_work)).to be_nil
      end
    end
  end
end
