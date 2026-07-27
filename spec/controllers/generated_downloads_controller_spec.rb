# frozen_string_literal: true

require "spec_helper"

describe GeneratedDownloadsController do
  describe "GET #show" do
    it "returns accepted while the file is being generated" do
      download = GeneratedDownload.create!(kind: "test", arguments: {}, filename: "test.csv")

      get :show, params: { token: download.token }

      expect(response).to have_http_status(:accepted)
    end

    it "returns gone after the download expires" do
      download = GeneratedDownload.create!(
        kind: "test",
        arguments: {},
        filename: "test.csv",
        expires_at: 1.minute.ago
      )

      get :show, params: { token: download.token }

      expect(response).to have_http_status(:gone)
    end
  end
end
