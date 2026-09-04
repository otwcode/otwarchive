# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the admin users controller" do
  include LoginMacros

  describe "#show", n_plus_one: true do
    let!(:user) { create(:user) }
    let!(:admin) { create(:policy_and_abuse_admin) }

    before { fake_login_admin(admin) }

    populate do |n|
      role_names = %w[archivist no_resets official opendoors protected_user]
      # Assigning roles also creates the role-change history rendered on this page.
      user.reload.roles = role_names.first(n).map { |name| create(:role, name: name) }
    end

    warmup { get admin_user_path(user) }

    it "performs a constant number of role queries" do
      expect do
        get admin_user_path(user)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("user_history")
      end.to perform_constant_number_of_queries
        .matching(/\b(?:roles|roles_users)\b/)
        .with_scale_factors(2, 5)
    end
  end
end
