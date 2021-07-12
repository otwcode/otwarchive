require "spec_helper"

describe ZohoResourceClient do
  let(:resource_params) do
    {
      access_token: "1a2b3c",
      email: "email@example.org"
    }
  end

  let(:expected_headers) do
    {
      "Content-Type" => "application/json",
      "orgId" => "123",
      "Authorization" => "Zoho-oauthtoken 1a2b3c"
    }
  end

  let(:subject) { ZohoResourceClient.new(resource_params) }

  let(:search_response) { double(:response, body: '{"data":[{"id":"1"}]}') }
  let(:contact_create_response) { double(:response, body: '{"id":"2"}') }

  before do
    stub_const("ArchiveConfig", OpenStruct.new(ArchiveConfig))
    ArchiveConfig.ZOHO_ORG_ID = "123"

    allow(HTTParty).to receive(:get).and_return(search_response)
    allow(HTTParty).to receive(:post)
  end

  describe "#retrieve_contact_id" do
    it "makes a get request to the correct endpoint with the expected arguments" do
      subject.retrieve_contact_id

      expect(HTTParty).to have_received(:get).
        with("https://desk.zoho.com/api/v1/contacts/search",
             query: { email: "email@example.org", limit: 1, sortBy: "modifiedTime" },
             headers: expected_headers)
    end

    it "returns the contact id" do
      expect(subject.retrieve_contact_id).to eq("1")
    end

    it "does not attempt to create a new one" do
      subject.retrieve_contact_id

      expect(HTTParty).to_not have_received(:post)
    end

    context "when no contact was found" do
      before do
        allow(HTTParty).to receive(:get).and_return(nil)
        allow(HTTParty).to receive(:post).and_return(contact_create_response)
      end

      it "creates a new contact using the email for the required field lastName" do
        subject.retrieve_contact_id

        expect(HTTParty).to have_received(:post).
          with("https://desk.zoho.com/api/v1/contacts",
               headers: expected_headers,
               body: { "lastName" => "email@example.org", "email" => "email@example.org" }.to_json)
      end

      it "returns the new contact id" do
        expect(subject.retrieve_contact_id).to eq("2")
      end
    end
  end

  describe "#create_ticket" do
    let(:minimum_viable_ticket_attrs) do
      { foo: "bar" }
    end

    let(:ticket_create_response) { double(:response, body: '{"id":"ticket_id"}') }

    before do
      allow(HTTParty).to receive(:post).and_return(ticket_create_response)
    end

    it "submits a post request to the correct endpoint with the expected arguments" do
      subject.create_ticket(ticket_attributes: minimum_viable_ticket_attrs)

      expect(HTTParty).to have_received(:post).
        with("https://desk.zoho.com/api/v1/tickets",
             headers: expected_headers,
             body: minimum_viable_ticket_attrs.to_json)
    end
  end
end
