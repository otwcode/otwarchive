# frozen_string_literal: true

require "spec_helper"

describe QuestionsController do
  include LoginMacros
  include RedirectExpectationHelper

  fully_authorized_roles = %w[superadmin docs support]

  shared_examples "an action only fully authorized admins can access" do
    before { fake_login_admin(admin) }

    context "with no role" do
      let(:admin) { create(:admin, roles: []) }

      it "redirects with an error" do
        subject
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - fully_authorized_roles).each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with an error" do
          subject
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    fully_authorized_roles.each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "succeeds" do
          subject
          success
        end
      end
    end
  end

  describe "GET #manage" do
    let(:faq) { create(:archive_faq) }
    subject { get :manage, params: { archive_faq_id: faq } }
    let(:success) do
      expect(response).to render_template(:manage)
    end

    it_behaves_like "an action only fully authorized admins can access"
  end

  describe "POST #update_positions" do
    let(:faq) { create(:archive_faq) }
    let!(:question1) { create(:question, archive_faq: faq, position: 1) }
    let!(:question2) { create(:question, archive_faq: faq, position: 2) }
    let!(:question3) { create(:question, archive_faq: faq, position: 3) }
    subject { post :update_positions, params: { archive_faq_id: faq, questions: [3, 1, 2] } }
    let(:success) do
      expect(question1.reload.position).to eq(3)
      expect(question2.reload.position).to eq(1)
      expect(question3.reload.position).to eq(2)
      it_redirects_to_with_notice(faq, "Question order has been successfully updated.")
    end

    it_behaves_like "an action only fully authorized admins can access"
  end
end
