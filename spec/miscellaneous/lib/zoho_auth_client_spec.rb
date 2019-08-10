require "spec_helper"

describe ZohoAuthClient do
  def stub_access_token_request
    allow(HTTParty).to receive(:post).and_return(response)
  end

  let(:response) { double(:response, body: '{"access_token":"1a2b3c"}') }

  before do
    stub_const("ArchiveConfig", OpenStruct.new(ArchiveConfig))
    ArchiveConfig.ZOHO_CLIENT_ID = "111"
    ArchiveConfig.ZOHO_CLIENT_SECRET = "a1b2c3"
    ArchiveConfig.ZOHO_REFRESH_TOKEN = "x1y2z3"
    ArchiveConfig.ZOHO_ORG_ID = "123"
    ArchiveConfig.ZOHO_REDIRECT_URI = "https://archiveofourown.org/support"

    stub_access_token_request
  end

  describe "#new" do
    context "when it cannot find the environment variables" do
      xit "raises an exception?"
    end

    context "with the right environment variables" do
      it "makes a well formed request" do
        ZohoAuthClient.new

        expect(HTTParty).to have_received(:post).
          with("https://accounts.zoho.com/oauth/v2/token",
               query: { client_id: "111",
                        client_secret: "a1b2c3",
                        redirect_uri: "https://archiveofourown.org/support",
                        scope: "Desk.tickets.ALL,Desk.contacts.READ,Desk.contacts.WRITE,Desk.contacts.CREATE,Desk.basic.READ,Desk.search.READ",
                        grant_type: "refresh_token",
                        refresh_token: "x1y2z3" })
      end
    end
  end

  describe "#access_token" do
    it "returns the access token from the response" do
      expect(ZohoAuthClient.new.access_token).to eq("1a2b3c")
    end
  end
end
