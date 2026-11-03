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

    it "redirects ready downloads to the storage service" do
      download = GeneratedDownload.create!(
        kind: "test",
        arguments: {},
        filename: "test.csv",
        status: "ready"
      )
      download.file.attach(
        io: StringIO.new("contents"),
        filename: download.filename,
        content_type: "text/csv"
      )
      blob = download.file.blob
      service_url = "https://downloads.example.test/test.csv"
      allow(blob.service).to receive(:url).and_return(service_url)

      get :show, params: { token: download.token }

      expect(response).to redirect_to(service_url)
      expect(blob.service).to have_received(:url).with(
        blob.key,
        expires_in: ActiveStorage.service_urls_expire_in,
        filename: blob.filename,
        content_type: blob.content_type,
        disposition: :attachment
      )
    end
  end
end
