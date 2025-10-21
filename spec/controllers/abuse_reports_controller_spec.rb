# frozen_string_literal: true

require "spec_helper"

describe AbuseReportsController do
  include LoginMacros

  describe "POST #create" do
    let(:mock_zoho) { instance_double(ZohoResourceClient) }

    let(:default_parameters) do
      {
        abuse_report: {
          comment: "Problem",
          url: "https://example.com/something",
          email: "test@example.com",
          summary: "Summary",
          language: "en"
        }
      }
    end

    before do
      allow(ArchiveConfig).to receive(:PERMITTED_HOSTS).and_return(["example.com"])
      allow_any_instance_of(AbuseReport).to receive(:zoho_enabled?).and_return(true)
      allow(mock_zoho).to receive(:retrieve_contact_id)
      allow_any_instance_of(AbuseReporter).to receive(:zoho_resource_client).and_return(mock_zoho)
    end

    it "specifies a channel" do
      expect(mock_zoho).to receive(:create_ticket).with(ticket_attributes: include(
        "channel" => "Abuse Form"
      )).and_return({})
      post :create, params: default_parameters
    end
  end
end
