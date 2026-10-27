# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the admin users controller" do
  include LoginMacros

  describe "#show", n_plus_one: true do
    context "when an admin views a user with multiple roles" do
      let!(:user) { create(:user) }

      before { fake_login_admin(create(:policy_and_abuse_admin)) }

      populate do |n|
        user.roles = create_list(:role, n)
      end

      subject do
        proc do
          get admin_user_path(user)
        end
      end

      warmup { subject.call }

      it "produces a constant number of queries" do
        expect { subject.call }
          .to perform_constant_number_of_queries

        expect(response).to have_http_status(:success)
        expect(response.body).to include("user_history")
      end
    end
  end
end
