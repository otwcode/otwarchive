# frozen_string_literal: true

require "spec_helper"

describe AbuseReporter do
  include ZohoClientSpecHelper

  let(:abuse_report_attributes) do
    {
      title: "This is a tragedy",
      description: "Nothing more to say",
      language: "English",
      email: "walrus@example.org",
      username: "Walrus",
      ip_address: "127.0.0.1",
      url: "https://example.com/works/1",
      creator_ids: "3, 4"
    }
  end

  let(:expected_ticket_attributes) do
    {
      "departmentId" => "abuse_dep_id",
      "email" => "walrus@example.org",
      "contactId" => "1",
      "subject" => "[AO3] Abuse - This is a tragedy",
      "description" => "Nothing more to say",
      "channel" => "Abuse Form",
      "cf" => {
        "cf_language" => "English",
        "cf_name" => "Walrus",
        "cf_ip" => "127.0.0.1",
        "cf_ticket_url" => "https://example.com/works/1",
        "cf_user_id" => "3, 4",
        "cf_user_agent" => "Unknown user agent"
      }
    }
  end

  before(:each) do
    stub_const("ArchiveConfig", OpenStruct.new(ArchiveConfig))
    ArchiveConfig.ABUSE_ZOHO_DEPARTMENT_ID = "abuse_dep_id"

    stub_zoho_auth_client
    stub_zoho_resource_client
  end

  let(:subject) { AbuseReporter.new(abuse_report_attributes) }

  describe "#report_attributes" do
    it "returns the expected attributes" do
      expect(subject.report_attributes).to eq(expected_ticket_attributes)
    end

    context "if the report has an empty title" do
      it "returns a hash containing a placeholder subject" do
        allow(subject).to receive(:title).and_return("")

        expect(subject.report_attributes.fetch("subject")).to eq("[AO3] Abuse - No Subject")
      end
    end

    context "if the report does not have a description" do
      it "returns a hash containing placeholder text" do
        allow(subject).to receive(:description).and_return("")

        expect(subject.report_attributes.fetch("description")).to eq("No comment submitted.")
      end
    end

    context "if the report does not have an IP address" do
      it "returns a hash containing 'Unknown IP'" do
        allow(subject).to receive(:ip_address).and_return("")

        expect(subject.report_attributes.fetch("cf").fetch("cf_ip")).to eq("Unknown IP")
      end
    end

    context "if the report has an empty URL" do
      before do
        allow(subject).to receive(:url).and_return("")
      end

      it "returns a hash containing a blank string for URL" do
        expect(subject.report_attributes.dig("cf", "cf_ticket_url")).to eq("")
      end
    end

    context "if the reporter has a very long URL" do
      before do
        allow(subject).to receive(:url).and_return("a" * 2081)
      end

      it "truncates the URL to 2080 characters" do
        expect(subject.report_attributes.dig("cf", "cf_ticket_url").length).to eq(2080)
      end
    end

    context "if the report has an image in description" do
      it "strips all img tags but leaves the HTML attributes" do
        allow(subject).to receive(:description).and_return('Hi!<img src="http://example.com/Camera-icon.svg">Bye!')

        expect(subject.report_attributes.fetch("description")).to eq('Hi!img src="http://example.com/Camera-icon.svg"Bye!')
      end
    end

    context "if the report does not have creator_ids" do
      it "returns a hash containing a blank string for the user id" do
        allow(subject).to receive(:creator_ids).and_return(nil)

        expect(subject.report_attributes.fetch("cf").fetch("cf_user_id")).to eq("")
      end
    end

    context "if an user agent is set" do
      let(:user_agent) { "Mozilla/5.0 (X11; Linux x86_64; rv:138.0) Gecko/20100101 Firefox/138.0" }
      before do
        allow(subject).to receive(:user_agent).and_return(user_agent)
      end

      it "returns a hash containing the user agent" do
        expect(subject.report_attributes.fetch("cf").fetch("cf_user_agent")).to eq(user_agent)
      end
    end
  end
end
