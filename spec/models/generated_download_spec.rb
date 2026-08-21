# frozen_string_literal: true

require "spec_helper"

describe GeneratedDownload do
  it "sets a token and expiration" do
    download = GeneratedDownload.create!(kind: "test", arguments: {}, filename: "test.csv")

    expect(download.token).to be_present
    expect(download.expires_at).to be_within(1.second).of(GeneratedDownload::EXPIRATION.from_now)
  end

  it "round trips non-empty job arguments" do
    download = GeneratedDownload.create!(
      kind: "test",
      arguments: { user_id: 42 },
      filename: "test.csv"
    )

    expect(download.reload.arguments).to eq("user_id" => 42)
  end

  describe ".cleanup" do
    it "removes expired records" do
      expired = GeneratedDownload.create!(
        kind: "test",
        arguments: {},
        filename: "test.csv",
        expires_at: 1.minute.ago
      )

      GeneratedDownload.cleanup

      expect(GeneratedDownload.exists?(expired.id)).to be(false)
    end
  end
end
