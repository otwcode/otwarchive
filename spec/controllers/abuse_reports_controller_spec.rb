# frozen_string_literal: true

require "spec_helper"

describe AbuseReportsController do
  include LoginMacros

  describe "POST #create" do
    success_response = { headers: { content_type: "application/json" }, body: '{"data":[{"id":"1"}]}' }.freeze
    failure_response = { status: 400, headers: { content_type: "application/json" }, body: "{}" }.freeze

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
      )).and_return(success_response)
      post :create, params: default_parameters
    end

    context "when the user agent is very long" do
      let(:user_agent) { "Mozilla/5.0 (X11; Linux x86_64; rv:138.0) Gecko/20100101 Firefox/138.0" * 10 }
      before do
        request.env["HTTP_USER_AGENT"] = user_agent
      end

      it "sets the truncated user agent in the Zoho ticket" do
        expect(mock_zoho).to receive(:create_ticket).with(ticket_attributes: include(
          "cf" => include(
            "cf_user_agent" => user_agent.to(499)
          )
        )).and_return(success_response)
        post :create, params: default_parameters
      end
    end

    context "when no user agent is set" do
      before do
        request.env["HTTP_USER_AGENT"] = nil
      end

      it "sets no user agent in the Zoho ticket" do
        expect(mock_zoho).to receive(:create_ticket).with(ticket_attributes: include(
          "cf" => include(
            "cf_user_agent" => "Unknown user agent"
          )
        )).and_return(success_response)
        post :create, params: default_parameters
      end
    end

    context "when the abuse report is invalid" do
      it "renders the new template with an error message" do
        post :create, params: default_parameters.deep_merge(abuse_report: { email: "not an email" })
        expect(response).to render_template(:new)
        expect(assigns[:abuse_report].errors.full_messages).to include("Email should look like an email address.")
      end
    end

    context "when Zoho does not accept the ticket" do
      it "renders the new template with an error message" do
        expect(mock_zoho).to receive(:create_ticket).and_return(failure_response)

        post :create, params: default_parameters

        expect(response).to render_template(:new)
        expect(flash[:error]).to include("Sorry, your report could not be submitted. Please try again later.")
      end
    end
  end
end
