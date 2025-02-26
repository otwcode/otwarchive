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
  end
end
