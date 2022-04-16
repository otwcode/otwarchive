require "spec_helper"

describe ZohoAuthClient do
  def stub_access_token_request
    allow(HTTParty).to receive(:post).and_return(response)
  end

  let(:response) do
    double(:response, body: '{"access_token":"1a2b3c","expires_in_sec":3600}')
  end

  before do
    stub_const("ArchiveConfig", OpenStruct.new(ArchiveConfig))
    ArchiveConfig.ZOHO_CLIENT_ID = "111"
    ArchiveConfig.ZOHO_CLIENT_SECRET = "a1b2c3"
    ArchiveConfig.ZOHO_REFRESH_TOKEN = "x1y2z3"
    ArchiveConfig.ZOHO_ORG_ID = "123"
    ArchiveConfig.ZOHO_REDIRECT_URI = "https://archiveofourown.org/support"

    stub_access_token_request
  end

  describe "#access_token" do
    it "makes a well formed request" do
      ZohoAuthClient.new.access_token

      expect(HTTParty).to have_received(:post).
        with("https://accounts.zoho.com/oauth/v2/token",
             query: { client_id: "111",
                      client_secret: "a1b2c3",
                      redirect_uri: "https://archiveofourown.org/support",
                      scope: "Desk.tickets.ALL,Desk.contacts.READ,Desk.contacts.WRITE,Desk.contacts.CREATE,Desk.basic.READ,Desk.search.READ",
                      grant_type: "refresh_token",
                      refresh_token: "x1y2z3" })
    end

    it "returns the access token from the response" do
      expect(ZohoAuthClient.new.access_token).to eq("1a2b3c")
    end

    it "caches the access token from the response" do
      ZohoAuthClient.new.access_token

      expect(Rails.cache.read(ZohoAuthClient::ACCESS_TOKEN_CACHE_KEY)).to \
        eq("1a2b3c")
    end

    it "returns the cached token if it's available" do
      Rails.cache.write(ZohoAuthClient::ACCESS_TOKEN_CACHE_KEY,
                        "1a2b3c-cached")

      expect(ZohoAuthClient.new.access_token).to eq("1a2b3c-cached")
      expect(HTTParty).not_to have_received(:post)
    end
  end
end
