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

    it "redirects ready downloads through the Active Storage redirect endpoint" do
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

      get :show, params: { token: download.token }

      expect(response).to redirect_to(
        rails_storage_redirect_path(blob.signed_id, blob.filename, disposition: :attachment)
      )
    end
  end
end
