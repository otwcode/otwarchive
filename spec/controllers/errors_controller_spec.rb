require "spec_helper"

describe ErrorsController do
  describe "404" do
    it "returns an HTML 404 page for .html" do
      get :"404", params: { format: :html }
      expect(response.status).to eq(404)
      expect(response.header["Content-Type"]).to eq("text/html; charset=utf-8")
    end

    it "returns an HTML 404 page for .htm" do
      get :"404", params: { format: :htm }
      expect(response.status).to eq(404)
      expect(response.header["Content-Type"]).to eq("text/html; charset=utf-8")
    end

    it "returns an HTML 404 page for .epub" do
      get :"404", params: { format: :epub }
      expect(response.status).to eq(404)
      expect(response.header["Content-Type"]).to eq("text/html; charset=utf-8")
    end
  end

  describe "500" do
    it "returns an HTML 500 page" do
      get :"500"
      expect(response.status).to eq(500)
      expect(response.header["Content-Type"]).to eq("text/html; charset=utf-8")
    end
  end

  describe "auth_error" do
    render_views

    it "returns an auth error page" do
      get "auth_error"
      expect(response.status).to eq(200)
      assert_select "title:contains('Auth Error')"
    end
  end
end
