# frozen_string_literal: true

require "spec_helper"

describe FeedbacksController do
  include LoginMacros

  describe "POST #create" do
    let(:mock_zoho) { instance_double(ZohoResourceClient) }

    let(:default_parameters) do
      {
        feedback: {
          comment: "Hello",
          email: "test@example.com",
          summary: "Summary",
          language: "en"
        }
      }
    end

    before do
      allow_any_instance_of(Feedback).to receive(:zoho_enabled?).and_return(true)
      allow(mock_zoho).to receive(:retrieve_contact_id)
      allow_any_instance_of(FeedbackReporter).to receive(:zoho_resource_client).and_return(mock_zoho)
    end

    it "specifies a channel" do
      expect(mock_zoho).to receive(:create_ticket).with(ticket_attributes: include(
        "channel" => "Support Form"
      ))
      post :create, params: default_parameters
    end

    context "when accessed by a logged-in user" do
      let(:user) { create(:user) }

      before do
        fake_login_known_user(user)
      end

      context "when the user has no skin set" do
        before do
          admin_setting = AdminSetting.default
          admin_setting.default_skin = Skin.default
          admin_setting.save(validate: false)
        end

        it "sets the skin title in the Zoho ticket" do
          expect(mock_zoho).to receive(:create_ticket).with(ticket_attributes: include(
            "cf" => include(
              "cf_site_skin" => Skin.default.title
            )
          ))
          post :create, params: default_parameters
        end
      end

      context "when the user has a public non-default skin set" do
        let(:skin) { create(:skin, :public) }

        before do
          user.preference.update!(skin: skin)
        end

        it "sets the skin title in the Zoho ticket" do
          expect(mock_zoho).to receive(:create_ticket).with(ticket_attributes: include(
            "cf" => include(
              "cf_site_skin" => skin.title
            )
          ))
          post :create, params: default_parameters
        end
      end

      context "when the user has a private skin set" do
        let(:skin) { create(:skin, author: user) }

        before do
          user.preference.update!(skin: skin)
        end

        it "sets the expected fields in the support ticket" do
          expect(mock_zoho).to receive(:create_ticket).with(ticket_attributes: include(
            "cf" => include(
              "cf_site_skin" => "Custom skin"
            )
          ))
          post :create, params: default_parameters
        end
      end
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
        ))
        post :create, params: default_parameters
        expect(assigns[:feedback].user_agent.length).to eq(500)
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
        ))
        post :create, params: default_parameters
        expect(assigns[:feedback].user_agent).to be_nil
      end
    end
  end
end
